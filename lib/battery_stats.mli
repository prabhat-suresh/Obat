type charging_status = Charging | Discharging | Full | Unkown
type t = { capacity : int; status : charging_status }

val get_battery_stats : unit -> t
