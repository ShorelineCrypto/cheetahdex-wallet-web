Summary

- Preserve `WalletConfig.isLegacyWallet` in `copy()` so legacy wallets route to `AuthRestoreRequested`.
- Sanitize legacy wallet names: replace non-alphanumeric (Unicode letters/digits) except "_" with "_".
- Resolve collisions by appending the lowest integer suffix (e.g., name, name_1, name_2, ...).
- Apply during legacy migration in `AuthBloc._onRestore`; delete legacy entry after success.

Why

Fixes a critical bug where some users can't log into wallets created with old versions and the wallet disappears.

Testing

- Create a legacy wallet with special characters and attempt login; verify migration uses sanitized unique name and signs in.
- Verify if a non-legacy wallet already has the sanitized name, the migrated wallet uses the lowest available _N suffix.

Notes

No API changes. Static analysis passes for changed files.
