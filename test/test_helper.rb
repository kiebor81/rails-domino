# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "domino"
require "minitest/autorun"
require "fileutils"
require "ostruct"
require "erb"
require "tmpdir"
