<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template name="custom_validatepasswd" mode="custom_script" match="/">
        <script src="{/root/gui/url}/scripts/passwd/passwd.js" type="text/javascript"></script>
        <script type="text/javascript" language="JavaScript">

            // Intercept existing form validation and add more stringent
            // password validation

            Event.observe(window, 'load', function() {

                // Override global function `fn_name` and test password input
                // `input` is a valid password before calling the original
                // `fn_name` to look after the rest of the validation.
                function intercept(fn_name, input) {
                    if (window[fn_name]) {
                        var orig = window[fn_name];
                        window[fn_name] = function() {
                            var result = passwd.validPassword(input.value);
                            if (!result.valid) {
                                alert(result.msg);
                            } else {
                                orig();
                            }
                        };
                    }
                }

                if (document.changepwdform) {

                    // Prevent the form from being submitted without the Save button being pressed.
                    document.changepwdform.onsubmit = function() {
                        return false;
                    };

                    // Forgotten password (user) - password-change.xsl
                    intercept('updateUserPw', document.changepwdform.password);

                } else if (document.userupdateform) {

                    // Prevent the form from being submitted without the Save button being pressed.
                    document.userupdateform.onsubmit = function() {
                        return false;
                    };

                    // Reset password (admin) - user-resetpw.xsl
                    intercept('updateUserPw', document.userupdateform.password);

                    // New user (admin) - user-new.xsl
                    intercept('update1', document.userupdateform.password);

                    // Change password (user) - user-pwupdate.xsl
                    intercept('doUpdate', document.userupdateform.newPassword);

                }

            });

        </script>
    </xsl:template>

</xsl:stylesheet>
