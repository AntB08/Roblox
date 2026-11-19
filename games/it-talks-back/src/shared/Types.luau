--!strict
-- Types shared by server and client: payload shapes and enums carried in attributes.

export type ToastKind = "info" | "success" | "warning" | "error"

-- Player attribute "Status"
export type Status = "Lobby" | "Alive" | "Hidden" | "Caged" | "Escaped"

-- Workspace attribute "RoundState"
export type RoundState = "Lobby" | "Playing" | "Results"

-- Monster attribute "Mood" (drives eye color and music/heartbeat on clients)
export type Mood = "Dormant" | "Calm" | "Alert" | "Chase"

return {}
