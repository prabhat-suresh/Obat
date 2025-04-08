open Obat

let () =
  Eio_main.run @@ fun env ->
  Eio.Switch.run (fun sw ->
      Eio.Fiber.fork ~sw (fun () ->
          let inotify = Eio_inotify.create () in
          let _ =
            Eio_inotify.add_watch inotify Config.config_file
              [ Inotify.S_Modify ]
          in
          while true do
            let _ = Eio_inotify.read inotify in
            Logs.info (fun m -> m "Configuration file changed, reloading...");
            Monitor.reload_config ();
            Monitor.reset_battery_state ()
          done);
      Monitor.monitor_battery_loop ~env)
