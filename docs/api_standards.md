# API Standards

## Validation Rules
> [!IMPORTANT]
> **NO CLIENT-SIDE VALIDATION**

- Do **NOT** implement any client-side validation logic (e.g., regex for email, length checks for passwords) on the UI or Logic layer.
- The application must always send the raw user input to the backend.
- Trust the backend response solely.

## Error Handling
- **200 OK**: The request was processed successfully.
- **417 Expectation Failed**: An application-level error occurred (e.g., "Invalid password", "User not found").
    - In this case, display the `error_message` field from the JSON response to the user.
- **Other Status Codes**: Handle as generic network errors.
