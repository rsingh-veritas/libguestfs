(* guestfs-inspection
 * Copyright (C) 2024 Veritas Technologies LLC
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License along
 * with this program; if not, see https://www.gnu.org/licenses/lgpl-3.0.en.html
 *)

open Std_utils

open Utils

(* Detrmine the VxVM volume type using the fstype command
 * This would help us determine the vxfs specific volumes.
 *)
let rec vxvmvol_type { Mountable.m_device=device }=
  Option.value ~default:"" (get_vxvmvol_type device)

and get_vxvmvol_type device =
  let r, out, err =
    commandr "/opt/VRTS/bin/fstyp" [ device ] in
  match r with
  | 0 -> Some (String.chomp out)
  | 2 -> None
  | _ -> failwithf "fstyp: %s: %s" device err
