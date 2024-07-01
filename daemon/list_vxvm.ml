(* guestfs-inspection/* libguestfs - the guestfsd daemon
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

open Unix
open Printf

open Std_utils
open Str
open Utils

let rec list_vxvm () =
  let a = command "vxdisk" ["-q"; "list"; "-p"; "-x"; "DG_NAME"] in
  let lines = String.nsplit "\n" a in
  let lines = List.map String.trim lines in
  let lines = List.filter ((<>) "") lines in

  (* Create a list of list *)
  let lines = List.filter_map (
    fun line ->
      let s = Str.regexp "[ \t\r\n]" in
      let str = Str.bounded_split s line 2 in
      match str with
      | [ a; b ] ->
        Some (sprintf "%s" b)
      | _-> None
  ) lines in

  (* Trim of all the whitespaces from each element of the list *)
  let lines = List.map String.trim lines in

  (* Skip the lines with "-" *)
  let lines = List.filter ((<>) "-") lines in
  let lines = List.sort_uniq compare lines in
  let _ = List.iter (eprintf "%s") lines in

  (* Import the disk group that is in the deported state *)
  let _ = List.map (
    fun x ->
      let r, out, err = commandr "vxdg" ["list"; x] in
      match r with
      | 0 -> None
      | _ ->
        Some (command "vxdg" ["-Cf"; "import"; x])
  ) lines in

  let out = command "vxprint" [ "-s"; "-F"; "%{dg_name}/%{v_name}"; "-A"; "-Q" ] in
  convert_vxvm_output ~prefix:"/dev/vx/dsk/" out

and convert_vxvm_output ?prefix out =
  let lines = String.nsplit "\n" out in

  (* Skip leading and trailing ("pvs", I'm looking at you) whitespace. *)
  let lines = List.map String.trim lines in

  (* Skip empty lines. *)
  let lines = List.filter ((<>) "") lines in

  (* Ignore "unknown device" message (RHBZ#1054761). *)
  let lines = List.filter ((<>) "unknown device") lines in

  (* Remove Duplicate elements *)
  let lines = List.sort_uniq compare lines in

  (* Add a prefix? *)
  let lines =
    match prefix with
    | None -> lines
    | Some prefix -> List.map ((^) prefix) lines in

  (* Sort and return. *)
  List.sort compare lines
