;; Identity Attestation Contract
;; Allows users to create and verify attestations about other identities
;; Works with the main identity registry

(define-constant ERR-UNAUTHORIZED (err u200))
(define-constant ERR-INVALID-INPUT (err u201))
(define-constant ERR-NOT-FOUND (err u202))
(define-constant ERR-ALREADY-EXISTS (err u203))
(define-constant ERR-EXPIRED (err u204))

;; Attestation types
(define-constant ATTESTATION-SKILL u1)
(define-constant ATTESTATION-EDUCATION u2)
(define-constant ATTESTATION-EMPLOYMENT u3)
(define-constant ATTESTATION-REFERENCE u4)

;; Attestation storage
(define-map attestations
  { attester: principal, subject: principal, attestation-type: uint, id: uint }
  {
    content: (buff 200),
    timestamp: uint,
    expiry: uint,
    verified: bool,
    confidence-score: uint
  }
)

;; Attestation counter for unique IDs
(define-data-var attestation-counter uint u0)

;; Reference to main identity contract
(define-data-var identity-contract principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.identity-registry)

;; Create an attestation
(define-public (create-attestation 
    (subject principal) 
    (attestation-type uint) 
    (content (buff 200))
    (expiry uint)
    (confidence-score uint))
  (let (
    (attestation-id (+ (var-get attestation-counter) u1))
    (attestation-key { attester: tx-sender, subject: subject, attestation-type: attestation-type, id: attestation-id })
  )
    (begin
      ;; Validate inputs
      (asserts! (<= attestation-type u4) ERR-INVALID-INPUT)
      (asserts! (>= attestation-type u1) ERR-INVALID-INPUT)
      (asserts! (> (len content) u0) ERR-INVALID-INPUT)
      (asserts! (> expiry block-height) ERR-INVALID-INPUT)
      (asserts! (<= confidence-score u100) ERR-INVALID-INPUT)
      (asserts! (not (is-eq tx-sender subject)) ERR-UNAUTHORIZED)
      
      ;; Check if attestation already exists
      (asserts! (is-none (map-get? attestations attestation-key)) ERR-ALREADY-EXISTS)
      
      ;; Create attestation
      (map-set attestations attestation-key {
        content: content,
        timestamp: block-height,
        expiry: expiry,
        verified: false,
        confidence-score: confidence-score
      })
      
      ;; Increment counter
      (var-set attestation-counter attestation-id)
      (ok attestation-id)
    )
  )
)

;; Verify an attestation (subject can verify)
(define-public (verify-attestation 
    (attester principal) 
    (attestation-type uint) 
    (attestation-id uint))
  (let (
    (attestation-key { attester: attester, subject: tx-sender, attestation-type: attestation-type, id: attestation-id })
    (attestation (map-get? attestations attestation-key))
  )
    (begin
      ;; Check if attestation exists
      (asserts! (is-some attestation) ERR-NOT-FOUND)
      
      ;; Check if not expired
      (asserts! (> (get expiry (unwrap-panic attestation)) block-height) ERR-EXPIRED)
      
      ;; Verify attestation
      (map-set attestations attestation-key 
               (merge (unwrap-panic attestation) { verified: true }))
      (ok true)
    )
  )
)

;; Get attestation
(define-read-only (get-attestation 
    (attester principal) 
    (subject principal) 
    (attestation-type uint) 
    (attestation-id uint))
  (let (
    (attestation-key { attester: attester, subject: subject, attestation-type: attestation-type, id: attestation-id })
  )
    (match (map-get? attestations attestation-key)
      attestation (ok attestation)
      ERR-NOT-FOUND
    )
  )
)

;; Check if attestation is valid (exists, verified, not expired)
(define-read-only (is-attestation-valid 
    (attester principal) 
    (subject principal) 
    (attestation-type uint) 
    (attestation-id uint))
  (let (
    (attestation-key { attester: attester, subject: subject, attestation-type: attestation-type, id: attestation-id })
    (attestation (map-get? attestations attestation-key))
  )
    (match attestation
      att (ok (and 
               (get verified att)
               (> (get expiry att) block-height)))
      (ok false)
    )
  )
)

;; Revoke attestation (only attester can revoke)
(define-public (revoke-attestation 
    (subject principal) 
    (attestation-type uint) 
    (attestation-id uint))
  (let (
    (attestation-key { attester: tx-sender, subject: subject, attestation-type: attestation-type, id: attestation-id })
  )
    (begin
      ;; Check if attestation exists
      (asserts! (is-some (map-get? attestations attestation-key)) ERR-NOT-FOUND)
      
      ;; Remove attestation
      (map-delete attestations attestation-key)
      (ok true)
    )
  )
)

;; Get current attestation counter
(define-read-only (get-attestation-counter)
  (ok (var-get attestation-counter))
)
