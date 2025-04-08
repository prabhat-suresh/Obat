let send_notification urgency_level summary body =
  let cmd =
    Printf.sprintf "notify-send -r 999999999 -u %s \"%s\" \"%s\"" urgency_level
      summary body
  in
  ignore (Sys.command cmd)
