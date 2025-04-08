type charging_status = Charging | Discharging | Full | Unkown
type t = { capacity : int; status : charging_status }

let read_battery_capacity () =
  In_channel.with_open_bin "/sys/class/power_supply/BAT0/capacity" (fun ic ->
      int_of_string @@ Option.get @@ In_channel.input_line ic)

let read_battery_status () =
  In_channel.with_open_bin "/sys/class/power_supply/BAT0/status" (fun ic ->
      In_channel.input_line ic |> Option.get |> function
      | "Charging" -> Charging
      | "Discharging" -> Discharging
      | "Full" -> Full
      | _ -> Unkown)

let get_battery_stats () =
  { capacity = read_battery_capacity (); status = read_battery_status () }
