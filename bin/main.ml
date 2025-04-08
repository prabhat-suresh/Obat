open Obat

let config_file = "/home/prabhat/.config/obat/config.toml"

let () =
  Eio_main.run @@ fun env ->
  Eio.Switch.run (fun sw ->
      Eio.Fiber.fork ~sw (fun () ->
          let inotify = Eio_inotify.create () in
          let _ =
            Eio_inotify.add_watch inotify config_file [ Inotify.S_Modify ]
          in
          while true do
            let event = Eio_inotify.read inotify in
            Logs.info (fun m -> m "Configuration file changed, reloading...");
            print_endline (Inotify.string_of_event event);
            Monitor.set_config @@ Config.read_config config_file;
            print_endline "Hello World\n"
          done);
      Monitor.monitor_battery_loop ~env)
