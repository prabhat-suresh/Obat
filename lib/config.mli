val config_file : string

type config = {
  low_threshold : int;
  critical_threshold : int;
  high_threshold : int;
  polling_interval : float;
  enable_hibernation : bool;
}

val read_config : string -> config
