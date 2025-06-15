# On-Chain Identity Registry

A comprehensive blockchain-based identity management system built on Stacks using Clarity smart contracts. This system provides secure identity registration, verification, reputation tracking, and attestation capabilities.

## 🚀 Features

### Core Identity Registry
- **Secure Registration**: Register identities with name and email validation
- **Identity Verification**: Admin-controlled verification system with authorized verifiers
- **Reputation System**: Community-driven reputation scoring with vote mechanisms
- **Update Capabilities**: Users can update their identity information
- **Input Validation**: Comprehensive validation to prevent invalid data entry

### Attestation System
- **Multiple Attestation Types**: Support for skill, education, employment, and reference attestations
- **Expiring Attestations**: Time-bound attestations with expiry mechanisms
- **Verification Process**: Subject-controlled attestation verification
- **Confidence Scoring**: Quality assessment for attestations (0-100 scale)
- **Revocation Support**: Attesters can revoke their attestations

## 🏗️ Architecture

The system consists of two main smart contracts:

1. **Identity Registry Contract** (`identity-registry.clar`)
   - Core identity management
   - Verification and reputation systems
   - Admin controls for verifier management

2. **Attestation Registry Contract** (`attestation-registry.clar`)
   - Attestation creation and management
   - Verification and expiry handling
   - Revocation mechanisms

## 🔧 Installation & Setup

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks CLI tools

### Setup
```bash
# Clone the repository
git clone <repository-url>
cd on-chain-identity-registry

# Install dependencies
clarinet integrate

# Check contract syntax
clarinet check

# Run tests
clarinet test
```

## 📖 Usage Guide

### Identity Registration

```clarity
;; Register a new identity
(contract-call? .identity-registry register "John Doe" "john@example.com")

;; Update existing identity
(contract-call? .identity-registry update-identity "John Smith" "johnsmith@example.com")

;; Get identity information
(contract-call? .identity-registry get-identity 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Verification System

```clarity
;; Add authorized verifier (admin only)
(contract-call? .identity-registry add-verifier 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)

;; Verify an identity (authorized verifiers only)
(contract-call? .identity-registry verify-identity 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)

;; Check verification status
(contract-call? .identity-registry is-verified 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
```

### Reputation System

```clarity
;; Vote on reputation (1 for positive, -1 for negative)
(contract-call? .identity-registry vote-reputation 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG 1)

;; Check reputation score
(contract-call? .identity-registry get-reputation 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
```

### Attestation System

```clarity
;; Create an attestation
(contract-call? .attestation-registry create-attestation 
  'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG  ; subject
  u1                                            ; skill attestation
  "Expert in Clarity smart contract development" ; content
  u1000                                         ; expiry block
  u95)                                          ; confidence score

;; Verify attestation (subject only)
(contract-call? .attestation-registry verify-attestation 
  'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5   ; attester
  u1                                            ; attestation type
  u1)                                           ; attestation ID

;; Check attestation validity
(contract-call? .attestation-registry is-attestation-valid
  'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5   ; attester
  'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG   ; subject
  u1                                            ; attestation type
  u1)                                           ; attestation ID
```

## 🔒 Security Features

- **Input Validation**: All inputs are validated for length and format
- **Authorization Controls**: Admin-only functions for verifier management
- **Duplicate Prevention**: Prevents duplicate registrations and attestations
- **Self-Action Protection**: Users cannot vote on their own reputation or attest to themselves
- **Expiry Mechanisms**: Time-bound attestations with automatic expiry
- **Error Handling**: Comprehensive error codes and handling

## 📊 Error Codes

### Identity Registry
- `u100`: Unauthorized action
- `u101`: Invalid input
- `u102`: Already registered
- `u103`: Invalid verifier
- `u404`: Not found

### Attestation Registry
- `u200`: Unauthorized action
- `u201`: Invalid input
- `u202`: Not found
- `u203`: Already exists
- `u204`: Expired

## �� Testing

Run the test suite:
```bash
clarinet test
```

Test individual contracts:
```bash
clarinet console
```

## 🛠️ Development

### Adding New Attestation Types
1. Define new constants in `attestation-registry.clar`
2. Update validation logic in `create-attestation`
3. Update documentation

### Extending Verification System
1. Add new verifier types in `identity-registry.clar`
2. Implement role-based access controls
3. Update admin functions

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team

## 🔄 Changelog

### Phase 2 Improvements
- **Bug Fixes**: Added comprehensive input validation and error handling
- **New Contract**: Added attestation registry for identity attestations
- **Enhanced Security**: Implemented authorization controls and duplicate prevention
- **New Functionality**: Reputation system, verification workflow, and attestation management
- **Updated Configuration**: Enhanced Clarinet.toml with proper dependencies and test accounts
