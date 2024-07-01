/* libguestfs - the guestfsd daemon
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
 */

#include <config.h>

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <dirent.h>
#include <error.h>

#include "daemon.h"

/* This is used to check if we have the vxvm utility
 * in place.
 */
int
optgroup_vxvm_available (void)
{
  CLEANUP_FREE char *err = NULL;
  int r;
  r = commandr (NULL, &err, "vxdctl", "list",  NULL);
  return r == 0;
}
