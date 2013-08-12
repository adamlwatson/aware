# for handling standard error formatting and response bodies
# Can be used in the case of something going wrong with a known defined error like this:
#
#       err = AwareServer::Error.new(AwareServer::Error::ERROR_UNKNOWN)
#       [500, {}, err.body()]
#
#       for a response like this:
#       {"success":false,"result":{"error_code":1,"error":"API endpoint not found. Try /version, /status, or a documented api call"}}
#
# Or can be used to report custom errors like so:
#
#     err = AwareServer::Error.new
#     [500, {}, err.body("10069", "This is a custom error message!")]
#
#     For a response like this:
#     {"success":false,"result":{"error_code":"10069","error":"This is a custom error message!"}}
#



module AwareServer
  class Error

    ERROR_UNKNOWN                 = 0
    ERROR_API_NOT_FOUND           = 1
    ERROR_INVALID_REQUEST_METHOD  = 2
    ERROR_REQUEST_TIMEOUT         = 3

    attr_accessor :code

    def initialize(code = nil)
      @code = code
    end

    def to_s
      case @code
        when ERROR_UNKNOWN
          "An unknown error has occurred. Tip: check http response code for more information."
        when ERROR_API_NOT_FOUND
          "API endpoint not found. Try /version, /status, or a documented api call"
        when ERROR_INVALID_REQUEST_METHOD
          "Invalid request method"
        when ERROR_REQUEST_TIMEOUT
          "The request has timed out"
        else
          ""
      end
    end

    # prepare an error response body
    # if you pass in args to create an error message not defined here,
    # the first should be an error code, the second should be an error message
    def body(*args)
      if args.count > 0
        {'error_code' => args[0], 'error' => args[1]}
      else
        {'error_code' => @code, 'error' => to_s}
      end
    end

  end
end