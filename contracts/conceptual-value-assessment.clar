;; Conceptual Value Assessment Contract
;; Simple assessment of concept value

(define-map valuation-frameworks
  { id: uint }
  {
    name: (string-utf8 64),
    description: (string-utf8 256),
    creator: principal
  }
)

(define-map concept-valuations
  { concept-id: uint, framework-id: uint }
  {
    value: uint,
    assessor: principal
  }
)

(define-data-var next-framework-id uint u0)

;; Register a new valuation framework
(define-public (register-framework (name (string-utf8 64)) (description (string-utf8 256)))
  (let
    ((framework-id (var-get next-framework-id)))

    ;; Store the framework
    (map-set valuation-frameworks
      { id: framework-id }
      {
        name: name,
        description: description,
        creator: tx-sender
      }
    )

    ;; Increment framework ID counter
    (var-set next-framework-id (+ framework-id u1))

    ;; Return the new framework ID
    (ok framework-id)
  )
)

;; Assess the value of a concept using a specific framework
(define-public (assess-concept (concept-id uint) (framework-id uint) (value uint))
  (begin
    (asserts! (is-some (map-get? valuation-frameworks { id: framework-id })) (err u404))
    (asserts! (and (> value u0) (<= value u100)) (err u400))

    (ok (map-set concept-valuations
      { concept-id: concept-id, framework-id: framework-id }
      {
        value: value,
        assessor: tx-sender
      }
    ))
  )
)

;; Get framework details
(define-read-only (get-framework (framework-id uint))
  (map-get? valuation-frameworks { id: framework-id })
)

;; Get concept valuation
(define-read-only (get-valuation (concept-id uint) (framework-id uint))
  (map-get? concept-valuations { concept-id: concept-id, framework-id: framework-id })
)
