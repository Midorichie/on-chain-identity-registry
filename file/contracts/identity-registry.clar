;; Enhanced On-Chain Identity Registry
;; Fixes: Added input validation, error handling, and security improvements
;; New functionality: Identity verification, reputation system, and admin controls

(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INVALID-INPUT (err u101))
(define-constant ERR-ALREADY-REGISTERED (err u102))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-INVALID-VERIFIER (err u103))

;; Contract owner for admin functions
(define-data-var contract-owner principal tx-sender)

;; Identity storage with enhanced fields
(define-map identities
  principal
  {
    name: (buff 50),
    email: (buff 50),
    timestamp: uint,
    verified: bool,
    reputation: uint,
    last-updated: uint
  }
)

;; Authorized verifiers map
(define-map authorized-verifiers principal bool)

;; Reputation tracking
(define-map reputation-votes
  { voter: principal, target: principal }
  { vote: int, timestamp: uint }
)

;; Input validation helper
(define-private (is-valid-input (name (buff 50)) (email (buff 50)))
  (and 
    (> (len name) u0)
    (< (len name) u51)
    (> (len email) u0)
    (< (len email) u51)
    (is-some (index-of email 0x40)) ;; Check for @ symbol in email
  )
)

;; Register identity with validation (Fixed bug: added input validation)
(define-public (register (name (buff 50)) (email (buff 50)))
  (let ((existing-identity (map-get? identities tx-sender)))
    (begin
      ;; Validate inputs
      (asserts! (is-valid-input name email) ERR-INVALID-INPUT)
      ;; Check if already registered
      (asserts! (is-none existing-identity) ERR-ALREADY-REGISTERED)
      ;; Register identity
      (map-set identities tx-sender {
        name: name,
        email: email,
        timestamp: block-height,
        verified: false,
        reputation: u0,
        last-updated: block-height
      })
      (ok true)
    )
  )
)

;; Update existing identity
(define-public (update-identity (name (buff 50)) (email (buff 50)))
  (let ((existing-identity (map-get? identities tx-sender)))
    (begin
      ;; Validate inputs
      (asserts! (is-valid-input name email) ERR-INVALID-INPUT)
      ;; Check if registered
      (asserts! (is-some existing-identity) ERR-NOT-FOUND)
      ;; Update identity
      (map-set identities tx-sender {
        name: name,
        email: email,
        timestamp: (get timestamp (unwrap-panic existing-identity)),
        verified: (get verified (unwrap-panic existing-identity)),
        reputation: (get reputation (unwrap-panic existing-identity)),
        last-updated: block-height
      })
      (ok true)
    )
  )
)

;; Get identity (enhanced error handling)
(define-read-only (get-identity (user principal))
  (match (map-get? identities user)
    identity (ok identity)
    ERR-NOT-FOUND
  )
)

;; Admin function: Add authorized verifier
(define-public (add-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-UNAUTHORIZED)
    (map-set authorized-verifiers verifier true)
    (ok true)
  )
)

;; Admin function: Remove authorized verifier
(define-public (remove-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-UNAUTHORIZED)
    (map-delete authorized-verifiers verifier)
    (ok true)
  )
)

;; Verify identity (only authorized verifiers)
(define-public (verify-identity (user principal))
  (let ((identity (map-get? identities user)))
    (begin
      ;; Check if caller is authorized verifier
      (asserts! (default-to false (map-get? authorized-verifiers tx-sender)) ERR-INVALID-VERIFIER)
      ;; Check if identity exists
      (asserts! (is-some identity) ERR-NOT-FOUND)
      ;; Update verification status
      (map-set identities user (merge (unwrap-panic identity) { verified: true }))
      (ok true)
    )
  )
)

;; Vote on reputation (positive or negative)
(define-public (vote-reputation (target principal) (vote int))
  (let (
    (existing-vote (map-get? reputation-votes { voter: tx-sender, target: target }))
    (target-identity (map-get? identities target))
  )
    (begin
      ;; Validate vote (-1 or 1)
      (asserts! (or (is-eq vote 1) (is-eq vote -1)) ERR-INVALID-INPUT)
      ;; Check if target exists
      (asserts! (is-some target-identity) ERR-NOT-FOUND)
      ;; Prevent self-voting
      (asserts! (not (is-eq tx-sender target)) ERR-UNAUTHORIZED)
      
      ;; Calculate new reputation
      (let (
        (current-rep (get reputation (unwrap-panic target-identity)))
        (vote-diff (if (is-some existing-vote)
                      (- vote (get vote (unwrap-panic existing-vote)))
                      vote))
        (new-rep (if (>= vote-diff 0)
                    (+ current-rep (to-uint vote-diff))
                    current-rep))
      )
        ;; Record vote
        (map-set reputation-votes { voter: tx-sender, target: target } 
                 { vote: vote, timestamp: block-height })
        ;; Update reputation
        (map-set identities target 
                 (merge (unwrap-panic target-identity) { reputation: new-rep }))
        (ok true)
      )
    )
  )
)

;; Check if identity is verified
(define-read-only (is-verified (user principal))
  (match (map-get? identities user)
    identity (ok (get verified identity))
    ERR-NOT-FOUND
  )
)

;; Get reputation score
(define-read-only (get-reputation (user principal))
  (match (map-get? identities user)
    identity (ok (get reputation identity))
    ERR-NOT-FOUND
  )
)

;; Check if user is authorized verifier
(define-read-only (is-authorized-verifier (user principal))
  (default-to false (map-get? authorized-verifiers user))
)

;; Get contract owner
(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)
