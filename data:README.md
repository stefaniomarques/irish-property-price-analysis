# Data Source

The raw data is not redistributed in this repository (see root README for why —
file size). It's public and free to download directly.

## How to get it

1. Go to [propertypriceregister.ie](https://www.propertypriceregister.ie)
2. Find the **"Download all records"** section
3. Click **"Download All"** — this downloads the complete national register as
   a single CSV (2010–present, ~800,000+ rows, updates continuously as new
   sales are registered)

## Columns

| Column | Description |
|---|---|
| Date of Sale (dd/mm/yyyy) | Date the sale was registered |
| Address | Property address |
| County | One of Ireland's 26 counties |
| Eircode | Irish postal code (mostly blank for pre-2015 sales, since Eircode launched in 2015) |
| Price (€) | Sale price |
| Not Full Market Price | Flags sales not at arm's-length market value |
| VAT Exclusive | Whether the price excludes VAT (relevant for new builds) |
| Description of Property | New or Second-Hand dwelling/apartment |
| Property Size Description | Floor area band (only populated for VAT-exclusive new builds, per PSRA methodology) |

## Cleaning steps applied

Before loading into the SQL schema in this repo, the raw CSV needs:
- Dates parsed from `dd/mm/yyyy` text to proper `DATE` type
- Price stripped of `€` and thousands commas, cast to `DECIMAL`
- `Not Full Market Price` / `VAT Exclusive` converted from `Yes`/`No` text to
  boolean

## License

Published by the Property Services Regulatory Authority (PSRA) under the
Regulations on the Re-use of Public Sector Information (S.I. No. 279 of 2005).
Free to re-use with acknowledgement of source.
