import Foundation
import OSLog

class FdMonitor {
    
    
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "com.komodo.wallet.fdmonitor", qos: .utility)
    private let logger = Logger(subsystem: "com.komodo.wallet", category: "fd-monitor")
    private var isRunning = false
    private var intervalSeconds: TimeInterval = 60.0
    private var lastCount: Int = 0
    private let detailThresholdPercent: Double = 0.8
    
    
    static let shared = FdMonitor()
    
    private init() {
        NSLog("FDMonitor: Singleton initialized")
    }
    
    
    func start(intervalSeconds: TimeInterval = 60.0) {
        NSLog("FDMonitor: start() called with interval=%.1f", intervalSeconds)
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            if self.isRunning {
                NSLog("FDMonitor: Already running, ignoring start request")
                self.logger.info("FD Monitor already running")
                return
            }
            
            self.intervalSeconds = intervalSeconds
            self.isRunning = true
            
            NSLog("FDMonitor: Logging initial FD status...")
            self.logFileDescriptorStatus(detailed: false)
            
            NSLog("FDMonitor: Creating and scheduling timer...")
            let timer = DispatchSource.makeTimerSource(queue: self.queue)
            timer.schedule(deadline: .now() + intervalSeconds, repeating: intervalSeconds)
            timer.setEventHandler { [weak self] in
                self?.logFileDescriptorStatus(detailed: false)
            }
            timer.resume()
            
            self.timer = timer
            
            NSLog("FDMonitor: Started successfully with interval=%.1f seconds", intervalSeconds)
            self.logger.notice("FD Monitor started with interval: \(intervalSeconds, privacy: .public) seconds")
            
            NSLog("FDMonitor: Logging detailed status for immediate verification...")
            self.logFileDescriptorStatus(detailed: true)
        }
    }
    
    func stop() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            if !self.isRunning {
                self.logger.info("FD Monitor not running")
                return
            }
            
            self.timer?.cancel()
            self.timer = nil
            self.isRunning = false
            
            self.logger.info("FD Monitor stopped")
        }
    }
    
    func getCurrentCount() -> [String: Any] {
        var result: [String: Any] = [:]
        
        queue.sync {
            let fdInfo = self.getFileDescriptorInfo()
            result = [
                "openCount": fdInfo.openCount,
                "tableSize": fdInfo.tableSize,
                "softLimit": fdInfo.softLimit,
                "hardLimit": fdInfo.hardLimit,
                "percentUsed": fdInfo.percentUsed,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        }
        
        return result
    }
    
    func logDetailedStatus() {
        queue.async { [weak self] in
            self?.logFileDescriptorStatus(detailed: true)
        }
    }
    
    
    private struct FdInfo {
        let openCount: Int
        let tableSize: Int
        let softLimit: Int
        let hardLimit: Int
        let percentUsed: Double
    }
    
    private func getFileDescriptorInfo() -> FdInfo {
        let tableSize = Int(getdtablesize())
        
        var rlimit = rlimit()
        getrlimit(RLIMIT_NOFILE, &rlimit)
        let softLimit = Int(rlimit.rlim_cur)
        let hardLimit = Int(rlimit.rlim_max)
        
        var openCount = 0
        for fd in 0..<tableSize {
            let fd32 = Int32(fd)
            errno = 0
            let flags = fcntl(fd32, F_GETFD, 0)
            if flags != -1 || errno != EBADF {
                openCount += 1
            }
        }
        
        let percentUsed = softLimit > 0 ? (Double(openCount) / Double(softLimit)) * 100.0 : 0.0
        
        return FdInfo(
            openCount: openCount,
            tableSize: tableSize,
            softLimit: softLimit,
            hardLimit: hardLimit,
            percentUsed: percentUsed
        )
    }
    
    private func logFileDescriptorStatus(detailed: Bool) {
        let fdInfo = getFileDescriptorInfo()
        
        let statusMsg = String(format: "FD Status: open=%d/%d (%.1f%%), table_size=%d, soft_limit=%d, hard_limit=%d",
                              fdInfo.openCount, fdInfo.softLimit, fdInfo.percentUsed,
                              fdInfo.tableSize, fdInfo.softLimit, fdInfo.hardLimit)
        
        NSLog("FDMonitor: %@", statusMsg)
        logger.info("\(statusMsg, privacy: .public)")
        
        let shouldLogDetails = detailed || 
                               fdInfo.percentUsed > (detailThresholdPercent * 100.0) ||
                               (fdInfo.openCount - lastCount) > 50
        
        if shouldLogDetails {
            NSLog("FDMonitor: FD count approaching limit or significant increase detected, logging details...")
            logger.info("FD count approaching limit or significant increase detected, logging details...")
            logDetailedFileDescriptors(maxSamples: 50)
        }
        
        lastCount = fdInfo.openCount
    }
    
    private func logDetailedFileDescriptors(maxSamples: Int) {
        let tableSize = Int(getdtablesize())
        var logged = 0
        var fdsByType: [String: Int] = [:]
        
        for fd in 0..<tableSize where logged < maxSamples {
            let fd32 = Int32(fd)
            errno = 0
            let flags = fcntl(fd32, F_GETFD, 0)
            
            if flags == -1 && errno == EBADF {
                continue // Not open
            }
            
            var pathBuffer = [CChar](repeating: 0, count: Int(MAXPATHLEN))
            let pathResult = fcntl(fd32, F_GETPATH, &pathBuffer)
            let path = pathResult != -1 ? String(cString: pathBuffer) : "<unknown>"
            
            var st = stat()
            let fstatResult = fstat(fd32, &st)
            
            var typeStr = "unknown"
            if fstatResult == 0 {
                let mode = st.st_mode
                if (mode & S_IFMT) == S_IFREG {
                    typeStr = "file"
                } else if (mode & S_IFMT) == S_IFDIR {
                    typeStr = "dir"
                } else if (mode & S_IFMT) == S_IFSOCK {
                    typeStr = "socket"
                } else if (mode & S_IFMT) == S_IFIFO {
                    typeStr = "pipe"
                } else if (mode & S_IFMT) == S_IFCHR {
                    typeStr = "char_dev"
                } else if (mode & S_IFMT) == S_IFBLK {
                    typeStr = "block_dev"
                }
            }
            
            fdsByType[typeStr, default: 0] += 1
            
            if logged < 20 { // Only log first 20 individual FDs to avoid spam
                logger.debug("  FD \(fd): type=\(typeStr) path=\(path)")
            }
            
            logged += 1
        }
        
        logger.info("FD breakdown by type:")
        for (type, count) in fdsByType.sorted(by: { $0.value > $1.value }) {
            logger.info("  \(type): \(count)")
        }
    }
}
