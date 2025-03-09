;; Abstract Idea Tokenization Contract - Simplified
;; Tokenizes abstract philosophical ideas as NFTs

(define-non-fungible-token idea uint)

(define-map idea-data
  { id: uint }
  {
    title: (string-utf8 64),
    description: (string-utf8 256),
    creator: principal,
    creation-time: uint
  }
)

(define-data-var next-idea-id uint u0)

;; Mint a new idea token
(define-public (mint-idea (title (string-utf8 64)) (description (string-utf8 256)))
  (let
    ((idea-id (var-get next-idea-id)))

    ;; Mint the NFT
    (try! (nft-mint? idea idea-id tx-sender))

    ;; Store the idea data
    (map-set idea-data
      { id: idea-id }
      {
        title: title,
        description: description,
        creator: tx-sender,
        creation-time: block-height
      }
    )

    ;; Increment idea ID counter
    (var-set next-idea-id (+ idea-id u1))

    ;; Return the new idea ID
    (ok idea-id)
  )
)

;; Transfer ownership of an idea
(define-public (transfer-idea (idea-id uint) (recipient principal))
  (begin
    ;; Transfer the NFT
    (try! (nft-transfer? idea idea-id tx-sender recipient))
    (ok true)
  )
)

;; Update an idea's description
(define-public (update-idea (idea-id uint) (new-description (string-utf8 256)))
  (match (map-get? idea-data { id: idea-id })
    idea-info
      (begin
        ;; Ensure the caller is the current owner
        (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? idea idea-id) (err u404))) (err u403))

        ;; Update the idea data
        (ok (map-set idea-data
          { id: idea-id }
          (merge idea-info { description: new-description })
        ))
      )
    (err u404)
  )
)

;; Get idea details
(define-read-only (get-idea (idea-id uint))
  (map-get? idea-data { id: idea-id })
)

;; Get the current owner of an idea
(define-read-only (get-idea-owner (idea-id uint))
  (nft-get-owner? idea idea-id)
)
