# frozen_string_literal: true

require "net/http"
require "json"
require "time"
require_relative "./coverage/check_action"
require_relative "./coverage/configuration"
require_relative "./coverage/utils/request"
require_relative "./coverage/utils/retrieve_commit_sha"
require_relative "./coverage/adapters/simple_cov_result"
require_relative "./coverage/adapters/simple_cov_json_result"
require_relative "./coverage/adapters/github_end_check_payload"
require_relative "./coverage/formatters/start_check_run"
require_relative "./coverage/formatters/end_check_run"

CheckAction.new.call
