type fsm = NotificationSent | PluggedIn | OnBatteryPower | Critical

let battery_state = ref OnBatteryPower
let conf = ref @@ Config.read_config "/home/prabhat/.config/obat/config.toml"
let set_config conf' = conf := conf'

let rec monitor_battery_loop ~env =
  let battery_stats = Battery_stats.get_battery_stats () in
  (match (battery_stats.status, !battery_state) with
  | Battery_stats.Charging, PluggedIn ->
      if battery_stats.capacity >= !conf.high_threshold then (
        Notification.send_notification "critical" "Sufficiently Charged"
          "Unplug power supply";
        battery_state := NotificationSent)
  | Battery_stats.Charging, OnBatteryPower | Battery_stats.Charging, Critical ->
      Notification.send_notification "normal" "Charging" "Plugged in";
      battery_state := PluggedIn
  | Battery_stats.Discharging, PluggedIn ->
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
        battery_state := NotificationSent)
  | Battery_stats.Full, _ ->
      Notification.send_notification "critical" "Battery Full"
        "Unplug power supply"
  | _, _ -> ());
  Eio.Time.sleep env#clock !conf.polling_interval;
  monitor_battery_loop ~env
