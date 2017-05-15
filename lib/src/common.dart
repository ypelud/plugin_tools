// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

/// Error thrown when a command needs to exit with a non-zero exit code.
class ToolExit extends Error {
  ToolExit(this.exitCode);

  final int exitCode;
}

Future<int> runAndStream(
    String executable, List<String> args, Directory workingDir) async {
  final Process process =
      await Process.start(executable, args, workingDirectory: workingDir.path);
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
  return process.exitCode;
}
