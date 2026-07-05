# Data Trust Model

My Kar should make the source and confidence of vehicle data clear.

## Data Classes

| Class             | Source                              | Trust Level     | Example                                   |
| ----------------- | ----------------------------------- | --------------- | ----------------------------------------- |
| User-entered      | Manual input from owner             | Medium          | Mileage note, maintenance title           |
| User-uploaded     | File or photo uploaded by owner     | Medium to high  | Service receipt, insurance PDF            |
| System-derived    | Created from user data by app logic | Medium          | Missing data prompt                       |
| AI-generated      | Generated from stored records       | Low until cited | Summary, answer, risk note                |
| Verified external | Future trusted integrations         | High            | Inspection record, service partner record |

## Trust Rules

- Never present AI-generated content as verified fact.
- AI answers must cite the stored record or explain that the data is missing.
- User-entered records can be corrected by the user.
- Uploaded documents should keep metadata: upload date, file type, linked vehicle, and optional expiry date.
- Deleting a vehicle must require confirmation because it may remove linked memory.
- Private documents must not be exposed in future sale or share flows without explicit user action.

## Missing Data Principle

It is better to say "not recorded yet" than to guess.

## Future Trust Upgrades

- Document OCR with confidence scores
- Service provider verification
- Vehicle inspection integrations
- Exportable vehicle memory packet
