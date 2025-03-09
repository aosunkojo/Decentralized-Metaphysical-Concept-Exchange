;; Memetic Propagation Tracking Contract
;; Simple tracking of idea propagation

(define-map memes
  { id: uint }
  {
    concept-id: uint,
    variant-name: (string-utf8 64),
    creator: principal
  }
)

(define-map propagations
  { id: uint }
  {
    meme-id: uint,
    channel: (string-utf8 32),
    reach: uint,
    propagator: principal
  }
)

(define-data-var next-meme-id uint u0)
(define-data-var next-propagation-id uint u0)

;; Register a new meme variant
(define-public (register-meme (concept-id uint) (variant-name (string-utf8 64)))
  (let
    ((meme-id (var-get next-meme-id)))

    ;; Store the meme
    (map-set memes
      { id: meme-id }
      {
        concept-id: concept-id,
        variant-name: variant-name,
        creator: tx-sender
      }
    )

    ;; Increment meme ID counter
    (var-set next-meme-id (+ meme-id u1))

    ;; Return the new meme ID
    (ok meme-id)
  )
)

;; Record a propagation event
(define-public (record-propagation (meme-id uint) (channel (string-utf8 32)) (reach uint))
  (begin
    (asserts! (is-some (map-get? memes { id: meme-id })) (err u404))

    (let
      ((propagation-id (var-get next-propagation-id)))

      ;; Store the propagation event
      (map-set propagations
        { id: propagation-id }
        {
          meme-id: meme-id,
          channel: channel,
          reach: reach,
          propagator: tx-sender
        }
      )

      ;; Increment propagation ID counter
      (var-set next-propagation-id (+ propagation-id u1))

      (ok propagation-id)
    )
  )
)

;; Get meme details
(define-read-only (get-meme (meme-id uint))
  (map-get? memes { id: meme-id })
)

;; Get propagation event details
(define-read-only (get-propagation (propagation-id uint))
  (map-get? propagations { id: propagation-id })
)

