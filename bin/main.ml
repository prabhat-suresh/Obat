open Obat

let () =
  Eio_main.run @@ fun env ->
  Eio.Switch.run (fun sw ->
      Eio.Fiber.fork ~sw (fun () ->
          let inotify = Eio_inotify.create () in
          (*creates a new inotify descriptor*)
          let _ =
            Eio_inotify.add_watch inotify
              (Filename.dirname Config.config_file)
              [ Inotify.S_Modify; Inotify.S_Create; Inotify.S_Delete ]
            (* sets up the descriptor to watch for modifications to the config directory, as most editors like vim, emacs write to a temporary file, delete the original file and rename the temporary one to the original *)
          in
          while true do
            print_endline "entering while loop";
            let _ = Eio_inotify.read inotify in
            (*when the file is modified*)
            Logs.info (fun m ->
                m "Configuration directory changed, reloading...");
            Monitor.reload_config ();
            Monitor.reset_battery_state ();
            print_endline "Configuration directory changed, reloading..."
          done);
      Monitor.monitor_battery_loop ~env)
