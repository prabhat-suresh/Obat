(** * main.ml * * Entry point for the Obat application. * Initializes the Eio
    runtime, sets up file system monitoring for configuration changes, * and
    starts the main battery monitoring loop. *)

open Obat (* Import modules from the Obat library *)

let () =
  (* Initialize and run the Eio concurrent runtime system. *)
  Eio_main.run @@ fun env ->
  (* Create a switch to manage the lifecycle of concurrent fibers and resources. *)
  Eio.Switch.run (fun sw ->
      (* --- Resource Management for Inotify --- *)
      (* Create the inotify instance directly under the switch's scope. *)
      let inotify = Eio_inotify.create () in
      (* Ensure the inotify file descriptor is closed when the switch finishes.
         `Eio_inotify.t` likely wraps an `Eio_unix.Fd.t`, which is closeable.
         We assume `Eio_inotify.close` exists or access the underlying fd.
         If `Eio_inotify.close` doesn't exist, use `Eio.Flow.close inotify.fd`
         (assuming `inotify` has a public `fd` field of type `Eio_unix.Fd.t`).
         Let's assume a close function exists for simplicity: *)
      Eio.Switch.on_release sw (fun () ->
          Logs.debug (fun m -> m "Closing inotify descriptor");
          (* Replace with the actual closing function for Eio_inotify.t *)
          try Eio_inotify.close inotify (* Or Eio.Flow.close inotify.fd *)
          with Unix.Unix_error (e, _, _) ->
            Logs.warn (fun m ->
                m "Error closing inotify fd: %s" (Unix.error_message e)));

      (* --- End Resource Management --- *)

      (* Fork a new concurrent fiber to monitor the configuration file for changes.
         Pass the already created and managed 'inotify' instance. *)
      Eio.Fiber.fork ~sw (fun () ->
          try
            (* Add try-with inside the loop for robustness against non-fatal errors *)
            while true do
              (* Add watch - ignore descriptor *)
              let _ =
                Eio_inotify.add_watch inotify Config.config_file
                  [ Inotify.S_Modify ]
              in
              (* Block until event *)
              let _ = Eio_inotify.read inotify in

              (* Reload logic *)
              Logs.info (fun m -> m "Configuration file changed, reloading...");
              Monitor.reload_config ();
              Monitor.reset_battery_state ();
              print_endline "Configuration file changed, reloading..."
            done
          with
          (* Handle specific, potentially recoverable errors inside the loop if needed *)
          | Eio.Cancel.Cancelled ex ->
              Logs.info (fun m ->
                  m "Config watcher cancelled: %s" (Printexc.to_string ex));
              raise (Eio.Cancel.Cancelled ex) (* Re-raise cancellation *)
          | ex ->
              (* Log unexpected errors in the watcher loop, but let the fiber die,
                 which will likely terminate the application via the switch. *)
              Logs.err (fun m ->
                  m "Error in config watcher fiber: %s\n%s"
                    (Printexc.to_string ex)
                    (Printexc.get_backtrace ()));
              raise_notrace ex
          (* Propagate the exception to the switch *));
      (* Start the main battery monitoring loop. *)
      Monitor.monitor_battery_loop ~env)
(* Program runs until switch 'sw' finishes (e.g., due to error or main loop exit) *)
