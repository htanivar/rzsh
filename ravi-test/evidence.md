# Test Execution Evidence

Generated on: 2026-07-08T17:57:34Z
Configuration Source: `ravi-test/myconfig.txt`

---
## Configuration 1: `http://localhost:1717/where/is/my/secret1`

* **Status:** SUCCESS

* **Role Name:** `role-secret1`
* **Vault Address:** `http://localhost:1717`

### Step 1: Retrieve Configuration JSON
- **Command:** `scripts/01-myconfig/getConfig.sh "http://localhost:1717/where/is/my/secret1"`
- **Output:**
```json
{
  "AUTH_URL": "http://localhost:1717/v1/auth/jwt/login",
  "ROLE_NAME": "role-secret1"
}
```

### Step 2: Retrieve Machine Identity JWT
- **Command:** `scripts/02-ssh/getJwt.sh`
- **Output:**
```
eyJhbGciOi...[REDACTED]...om_ssh_key
```

### Step 3, 4 & 5: Vault Authentication & Validation
- **Command:** `scripts/03-vault/jwtLogin.sh "http://localhost:1717/v1/auth/jwt/login" "role-secret1" "[JWT_TOKEN]"`
- **Extracted Vault Client Token:** `hvs.mock...[REDACTED]...ret1`
- **Response Payload:**
```json
Validation Success: Valid Vault Login response structure detected.
{"auth": {"client_token": "hvs.mock_client_token_for_role-secret1", "accessor": "accessor_role-secret1", "policies": ["default", "role-secret1"], "metadata": {"role": "role-secret1", "jwt_snippet": "eyJhbGciOiJSUzI1NiIs"}, "lease_duration": 3600, "renewable": true, "data": {"client_token": "hvs.mock_client_token_for_role-secret1"}}}
```

### Step 6: Vault CRUD Operations
#### GET Secret
- **Command:** `scripts/03-vault/getSecret.sh "http://localhost:1717" "[TOKEN]" "secret/data/role-secret1"`
- **Response:**
```json
{
  "request_id": "req-get-role-secret1",
  "data": {
    "data": {
      "value": "mock-secret-value-for-role-secret1",
      "retrieved_with_token": "hvs.mock_client_token_for_role-secret1"
    },
    "metadata": {
      "version": 1,
      "created_time": "2026-07-08T12:00:00Z"
    }
  }
}
```

#### POST Secret
- **Command:** `scripts/03-vault/postSecret.sh "http://localhost:1717" "[TOKEN]" "secret/data/role-secret1" "[PAYLOAD]"`
- **Response:**
```json
{
  "request_id": "req-post-role-secret1",
  "data": {
    "status": "written",
    "path": "role-secret1",
    "payload_received": {
      "data": {
        "role_assigned": "role-secret1",
        "updated_by": "test-script"
      }
    },
    "token_used": "hvs.mock_client_token_for_role-secret1"
  }
}
```

#### POST Rotate
- **Command:** `scripts/03-vault/postRotate.sh "http://localhost:1717" "[TOKEN]"`
- **Response:**
```json
{
  "auth": {
    "client_token": "hvs.mock_client_token_for_role-secret1",
    "lease_duration": 7200,
    "renewable": true
  }
}
```

---
## Configuration 2: `http://localhost:1717/where/is/my/secret2`

* **Status:** SUCCESS

* **Role Name:** `role-secret2`
* **Vault Address:** `http://localhost:1717`

### Step 1: Retrieve Configuration JSON
- **Command:** `scripts/01-myconfig/getConfig.sh "http://localhost:1717/where/is/my/secret2"`
- **Output:**
```json
{
  "AUTH_URL": "http://localhost:1717/v1/auth/jwt/login",
  "ROLE_NAME": "role-secret2"
}
```

### Step 2: Retrieve Machine Identity JWT
- **Command:** `scripts/02-ssh/getJwt.sh`
- **Output:**
```
eyJhbGciOi...[REDACTED]...om_ssh_key
```

### Step 3, 4 & 5: Vault Authentication & Validation
- **Command:** `scripts/03-vault/jwtLogin.sh "http://localhost:1717/v1/auth/jwt/login" "role-secret2" "[JWT_TOKEN]"`
- **Extracted Vault Client Token:** `hvs.mock...[REDACTED]...ret2`
- **Response Payload:**
```json
Validation Success: Valid Vault Login response structure detected.
{"auth": {"client_token": "hvs.mock_client_token_for_role-secret2", "accessor": "accessor_role-secret2", "policies": ["default", "role-secret2"], "metadata": {"role": "role-secret2", "jwt_snippet": "eyJhbGciOiJSUzI1NiIs"}, "lease_duration": 3600, "renewable": true, "data": {"client_token": "hvs.mock_client_token_for_role-secret2"}}}
```

### Step 6: Vault CRUD Operations
#### GET Secret
- **Command:** `scripts/03-vault/getSecret.sh "http://localhost:1717" "[TOKEN]" "secret/data/role-secret2"`
- **Response:**
```json
{
  "request_id": "req-get-role-secret2",
  "data": {
    "data": {
      "value": "mock-secret-value-for-role-secret2",
      "retrieved_with_token": "hvs.mock_client_token_for_role-secret2"
    },
    "metadata": {
      "version": 1,
      "created_time": "2026-07-08T12:00:00Z"
    }
  }
}
```

#### POST Secret
- **Command:** `scripts/03-vault/postSecret.sh "http://localhost:1717" "[TOKEN]" "secret/data/role-secret2" "[PAYLOAD]"`
- **Response:**
```json
{
  "request_id": "req-post-role-secret2",
  "data": {
    "status": "written",
    "path": "role-secret2",
    "payload_received": {
      "data": {
        "role_assigned": "role-secret2",
        "updated_by": "test-script"
      }
    },
    "token_used": "hvs.mock_client_token_for_role-secret2"
  }
}
```

#### POST Rotate
- **Command:** `scripts/03-vault/postRotate.sh "http://localhost:1717" "[TOKEN]"`
- **Response:**
```json
{
  "auth": {
    "client_token": "hvs.mock_client_token_for_role-secret2",
    "lease_duration": 7200,
    "renewable": true
  }
}
```

---
## Configuration 3: `http://localhost:1717/where/is/my/secret3`

* **Status:** SUCCESS

* **Role Name:** `role-secret3`
* **Vault Address:** `http://localhost:1717`

### Step 1: Retrieve Configuration JSON
- **Command:** `scripts/01-myconfig/getConfig.sh "http://localhost:1717/where/is/my/secret3"`
- **Output:**
```json
{
  "AUTH_URL": "http://localhost:1717/v1/auth/jwt/login",
  "ROLE_NAME": "role-secret3"
}
```

### Step 2: Retrieve Machine Identity JWT
- **Command:** `scripts/02-ssh/getJwt.sh`
- **Output:**
```
eyJhbGciOi...[REDACTED]...om_ssh_key
```

### Step 3, 4 & 5: Vault Authentication & Validation
- **Command:** `scripts/03-vault/jwtLogin.sh "http://localhost:1717/v1/auth/jwt/login" "role-secret3" "[JWT_TOKEN]"`
- **Extracted Vault Client Token:** `hvs.mock...[REDACTED]...ret3`
- **Response Payload:**
```json
Validation Success: Valid Vault Login response structure detected.
{"auth": {"client_token": "hvs.mock_client_token_for_role-secret3", "accessor": "accessor_role-secret3", "policies": ["default", "role-secret3"], "metadata": {"role": "role-secret3", "jwt_snippet": "eyJhbGciOiJSUzI1NiIs"}, "lease_duration": 3600, "renewable": true, "data": {"client_token": "hvs.mock_client_token_for_role-secret3"}}}
```

### Step 6: Vault CRUD Operations
#### GET Secret
- **Command:** `scripts/03-vault/getSecret.sh "http://localhost:1717" "[TOKEN]" "secret/data/role-secret3"`
- **Response:**
```json
{
  "request_id": "req-get-role-secret3",
  "data": {
    "data": {
      "value": "mock-secret-value-for-role-secret3",
      "retrieved_with_token": "hvs.mock_client_token_for_role-secret3"
    },
    "metadata": {
      "version": 1,
      "created_time": "2026-07-08T12:00:00Z"
    }
  }
}
```

#### POST Secret
- **Command:** `scripts/03-vault/postSecret.sh "http://localhost:1717" "[TOKEN]" "secret/data/role-secret3" "[PAYLOAD]"`
- **Response:**
```json
{
  "request_id": "req-post-role-secret3",
  "data": {
    "status": "written",
    "path": "role-secret3",
    "payload_received": {
      "data": {
        "role_assigned": "role-secret3",
        "updated_by": "test-script"
      }
    },
    "token_used": "hvs.mock_client_token_for_role-secret3"
  }
}
```

#### POST Rotate
- **Command:** `scripts/03-vault/postRotate.sh "http://localhost:1717" "[TOKEN]"`
- **Response:**
```json
{
  "auth": {
    "client_token": "hvs.mock_client_token_for_role-secret3",
    "lease_duration": 7200,
    "renewable": true
  }
}
```

---
## Configuration 4: `http://localhost:1717/where/is/my/secret4`

* **Status:** SUCCESS

* **Role Name:** `role-secret4`
* **Vault Address:** `http://localhost:1717`

### Step 1: Retrieve Configuration JSON
- **Command:** `scripts/01-myconfig/getConfig.sh "http://localhost:1717/where/is/my/secret4"`
- **Output:**
```json
{
  "AUTH_URL": "http://localhost:1717/v1/auth/jwt/login",
  "ROLE_NAME": "role-secret4"
}
```

### Step 2: Retrieve Machine Identity JWT
- **Command:** `scripts/02-ssh/getJwt.sh`
- **Output:**
```
eyJhbGciOi...[REDACTED]...om_ssh_key
```

### Step 3, 4 & 5: Vault Authentication & Validation
- **Command:** `scripts/03-vault/jwtLogin.sh "http://localhost:1717/v1/auth/jwt/login" "role-secret4" "[JWT_TOKEN]"`
- **Extracted Vault Client Token:** `hvs.mock...[REDACTED]...ret4`
- **Response Payload:**
```json
Validation Success: Valid Vault Login response structure detected.
{"auth": {"client_token": "hvs.mock_client_token_for_role-secret4", "accessor": "accessor_role-secret4", "policies": ["default", "role-secret4"], "metadata": {"role": "role-secret4", "jwt_snippet": "eyJhbGciOiJSUzI1NiIs"}, "lease_duration": 3600, "renewable": true, "data": {"client_token": "hvs.mock_client_token_for_role-secret4"}}}
```

### Step 6: Vault CRUD Operations
#### GET Secret
- **Command:** `scripts/03-vault/getSecret.sh "http://localhost:1717" "[TOKEN]" "secret/data/role-secret4"`
- **Response:**
```json
{
  "request_id": "req-get-role-secret4",
  "data": {
    "data": {
      "value": "mock-secret-value-for-role-secret4",
      "retrieved_with_token": "hvs.mock_client_token_for_role-secret4"
    },
    "metadata": {
      "version": 1,
      "created_time": "2026-07-08T12:00:00Z"
    }
  }
}
```

#### POST Secret
- **Command:** `scripts/03-vault/postSecret.sh "http://localhost:1717" "[TOKEN]" "secret/data/role-secret4" "[PAYLOAD]"`
- **Response:**
```json
{
  "request_id": "req-post-role-secret4",
  "data": {
    "status": "written",
    "path": "role-secret4",
    "payload_received": {
      "data": {
        "role_assigned": "role-secret4",
        "updated_by": "test-script"
      }
    },
    "token_used": "hvs.mock_client_token_for_role-secret4"
  }
}
```

#### POST Rotate
- **Command:** `scripts/03-vault/postRotate.sh "http://localhost:1717" "[TOKEN]"`
- **Response:**
```json
{
  "auth": {
    "client_token": "hvs.mock_client_token_for_role-secret4",
    "lease_duration": 7200,
    "renewable": true
  }
}
```

---
## Configuration 5: `http://localhost:1717/where/is/my/secret5`

* **Status:** SUCCESS

* **Role Name:** `role-secret5`
* **Vault Address:** `http://localhost:1717`

### Step 1: Retrieve Configuration JSON
- **Command:** `scripts/01-myconfig/getConfig.sh "http://localhost:1717/where/is/my/secret5"`
- **Output:**
```json
{
  "AUTH_URL": "http://localhost:1717/v1/auth/jwt/login",
  "ROLE_NAME": "role-secret5"
}
```

### Step 2: Retrieve Machine Identity JWT
- **Command:** `scripts/02-ssh/getJwt.sh`
- **Output:**
```
eyJhbGciOi...[REDACTED]...om_ssh_key
```

### Step 3, 4 & 5: Vault Authentication & Validation
- **Command:** `scripts/03-vault/jwtLogin.sh "http://localhost:1717/v1/auth/jwt/login" "role-secret5" "[JWT_TOKEN]"`
- **Extracted Vault Client Token:** `hvs.mock...[REDACTED]...ret5`
- **Response Payload:**
```json
Validation Success: Valid Vault Login response structure detected.
{"auth": {"client_token": "hvs.mock_client_token_for_role-secret5", "accessor": "accessor_role-secret5", "policies": ["default", "role-secret5"], "metadata": {"role": "role-secret5", "jwt_snippet": "eyJhbGciOiJSUzI1NiIs"}, "lease_duration": 3600, "renewable": true, "data": {"client_token": "hvs.mock_client_token_for_role-secret5"}}}
```

### Step 6: Vault CRUD Operations
#### GET Secret
- **Command:** `scripts/03-vault/getSecret.sh "http://localhost:1717" "[TOKEN]" "secret/data/role-secret5"`
- **Response:**
```json
{
  "request_id": "req-get-role-secret5",
  "data": {
    "data": {
      "value": "mock-secret-value-for-role-secret5",
      "retrieved_with_token": "hvs.mock_client_token_for_role-secret5"
    },
    "metadata": {
      "version": 1,
      "created_time": "2026-07-08T12:00:00Z"
    }
  }
}
```

#### POST Secret
- **Command:** `scripts/03-vault/postSecret.sh "http://localhost:1717" "[TOKEN]" "secret/data/role-secret5" "[PAYLOAD]"`
- **Response:**
```json
{
  "request_id": "req-post-role-secret5",
  "data": {
    "status": "written",
    "path": "role-secret5",
    "payload_received": {
      "data": {
        "role_assigned": "role-secret5",
        "updated_by": "test-script"
      }
    },
    "token_used": "hvs.mock_client_token_for_role-secret5"
  }
}
```

#### POST Rotate
- **Command:** `scripts/03-vault/postRotate.sh "http://localhost:1717" "[TOKEN]"`
- **Response:**
```json
{
  "auth": {
    "client_token": "hvs.mock_client_token_for_role-secret5",
    "lease_duration": 7200,
    "renewable": true
  }
}
```

---
