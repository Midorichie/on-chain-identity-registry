(define-map identities
  principal
  {
    name: (buff 50),
    email: (buff 50),
    timestamp: uint
  }
)

(define-public (register (name (buff 50)) (email (buff 50)))
  (begin
    (map-set identities tx-sender {
      name: name,
      email: email,
      timestamp: block-height
    })
    (ok true)
  )
)

(define-read-only (get-identity (user principal))
  (match (map-get? identities user)
    identity (ok identity)
    (err u404)
  )
)
