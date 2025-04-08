val reset_battery_state : unit -> unit
val reload_config : unit -> unit

val monitor_battery_loop :
  env:< clock : [> float Eio.Time.clock_ty ] Eio.Resource.t ; .. > -> 'a
