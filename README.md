# snap_theme

## Structure globale
```
rooms/{roomId}
 ├── code: string
 ├── hostId: string
 ├── status: string (waiting | playing | voting | finished)
 ├── maxPlayers: number (ex: 6)
 ├── currentRound: number
 ├── maxRound : number (ex:12)
 │
 ├── players/{playerId}
 │    ├── displayName: string
 │    ├── joinedAt: Timestamp
 │    ├── canCapture: boolean
 │    ├── isSpectator: boolean
 │    └── score: number
 │
 ├── rounds/{roundNumber}
 │    ├── theme: string
 │    ├── status: string (playing | voting | finished)
 │    ├── endsAt: Timestamp
 │    │
 │    └── submissions/{playerId}
 │         ├── sendsAt: Timestamp
 │         └── photoUrl: string
 │
 ├── votes/{roundNumber}_{voterId}
 │    └── votedForPlayerId: string
 │
 └── scores/{playerId}
      ├── points: number
      └── displayName: string
```