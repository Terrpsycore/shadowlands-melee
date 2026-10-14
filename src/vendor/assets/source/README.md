# WC3 reference sources (committed)

## `wc3_order_strings.csv`

Order ID strings for ability rows and dummy orders. Derived from the community order table:

- [Spreadsheet (edit)](https://docs.google.com/spreadsheets/d/10hNbIwFr4-y90pS5R9olWNT6lmD8-iZcBOafck58Xm4/edit?gid=0)
- [CSV export (gid=0)](https://docs.google.com/spreadsheets/d/10hNbIwFr4-y90pS5R9olWNT6lmD8-iZcBOafck58Xm4/export?format=csv&gid=0)

Only rows with a non-empty **order string** column are used. After replacing this file, run `lua tools/bake.lua` to regenerate `src/data/generated/Orders.lua`.
