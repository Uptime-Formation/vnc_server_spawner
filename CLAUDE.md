# Working conventions for this repo

- Never delete files or code that look outdated or unused. Instead: comment
  it out (or rename the file/dir with a `.outdated` suffix, or move it to
  `.trash/`), and add a one-line header noting who/when/why, e.g.:
  `# @alban: retired on YYYY-MM-DD, replaced by X`.
  This keeps history recoverable without relying on git archaeology.
