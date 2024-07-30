function isONline = checkInternetConnection()
    try
        % Go to Google's web page
        webread('http://www.google.com');
        isONline = true;
    catch
        % If an exception occurs, it is assumed to be offline
        isONline = false;
    end
end
