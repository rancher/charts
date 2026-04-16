## Dependency Checksum Mismatch Detected

- **Package:** {{PACKAGE_VERSION}}
- **Expected:** `{{EXPECTED_CHECKSUM}}`
- **Actual:** `{{ACTUAL_CHECKSUM}}`

---

### Manual update required

Ask a maintainer to update the dependencies.

#### What happened?
SUSE rebuilt this package in their repositories. The binary checksum changed even though the version stayed the same. This is normal behavior for SUSE packages (security patches, compiler updates, etc).

**This is expected behavior for security reasons and not an issue with your changes.**
