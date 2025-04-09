type fsm_state =
  | LowBatteryNotificationSent
  | ChargedNotificationSent
  | PluggedIn
  | OnBatteryPower
  | Critical

let battery_state = ref OnBatteryPower
let reset_battery_state () = battery_state := OnBatteryPower
let conf = ref @@ Config.read_config Config.config_file
let reload_config () = conf := Config.read_config Config.config_file

let rec monitor_battery_loop ~env =
  let battery_stats = Battery_stats.get_battery_stats () in
  (match (battery_stats.status, !battery_state) with
  | Battery_stats.Charging, ChargedNotificationSent -> ()
  | Battery_stats.Charging, PluggedIn ->
      if battery_stats.capacity >= !conf.high_threshold then (
        Notification.send_notification "critical" "Sufficiently Charged"
          "Unplug power supply";
        battery_state := ChargedNotificationSent)
  | Battery_stats.Charging, _ ->
      Notification.send_notification "normal" "Charging" "Plugged in";
      battery_state := PluggedIn
  | Battery_stats.Discharging, PluggedIn
  | Battery_stats.Discharging, ChargedNotificationSent ->
      Notification.send_notification "normal" "Discharging" "On Battery Power";
      battery_state := OnBatteryPower
  | Battery_stats.Discharging, OnBatteryPower ->
      if battery_stats.capacity <= !conf.low_threshold then (
        Notification.send_notification "critical" "Battery Low"
          "Plug in power supply";
        battery_state := Critical)
  | Battery_stats.Discharging, Critical ->
      if battery_stats.capacity <= !conf.critical_threshold then (
        Notification.send_notification "critical" "Battery Critical"
          "Preparing to hibernate system in 1 minute";
        battery_state := LowBatteryNotificationSent)
  | Battery_stats.Full, _ ->
      Notification.send_notification "critical" "Battery Full"
        "Unplug power supply";
      battery_state := ChargedNotificationSent
  | _, _ -> ());
  print_endline "before sleep";
  Eio.Time.sleep env#clock !conf.polling_interval;
  Printf.printf "low: %d, high: %d, critical: %d\n" !conf.low_threshold
    !conf.high_threshold !conf.critical_threshold;
  monitor_battery_loop ~env
