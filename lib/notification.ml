let obat_notification_id = 999999999

let send_notification urgency_level summary body =
  let cmd =
    Printf.sprintf "notify-send -r %d -u %s \"%s\" \"%s\"" obat_notification_id
      urgency_level summary body
  in
  ignore (Sys.command cmd)
