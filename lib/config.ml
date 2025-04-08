let config_file = "/home/prabhat/.config/obat/config.toml"

type config = {
  low_threshold : int;
  critical_threshold : int;
  high_threshold : int;
  polling_interval : float;
  enable_hibernation : bool;
}

let default_config =
  {
    low_threshold = 20;
    critical_threshold = 15;
    high_threshold = 80;
    polling_interval = 10.0;
    enable_hibernation = false;
  }

let read_config file =
  try
    let toml = Hashtbl.create 50 in
    Otoml.Parser.from_file file
    |> Otoml.get_table |> List.to_seq |> Hashtbl.add_seq toml;
    {
      low_threshold =
        (match Hashtbl.find_opt toml "low_threshold" with
        | Some low ->
            let low_thresh = Otoml.get_integer low in
            Printf.printf "low_theshold set at %d" low_thresh;
            low_thresh
        | None ->
            print_endline "low_threshold not found in config";
            default_config.low_threshold);
      critical_threshold =
        Otoml.get_integer @@ Hashtbl.find toml "critical_threshold";
      high_threshold = Otoml.get_integer @@ Hashtbl.find toml "high_threshold";
      polling_interval = Otoml.get_float @@ Hashtbl.find toml "polling_interval";
      enable_hibernation =
        Otoml.get_boolean @@ Hashtbl.find toml "enable_hibernation";
    }
  with Stdlib.Sys_error _ -> failwith "No config file found in ~/.config/obat"
