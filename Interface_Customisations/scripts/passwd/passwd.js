// Module
var passwd = {};

/**
 * Tests if a string is a valid password.
 * @returns {Boolean}
 */
passwd.validPassword = function(str) {

    function msg(reason) {
        return 'Your password must ' + reason;
    }

    if (!passwd.validLength(str)) {
        return {valid: false, msg: msg('be at least 8 characters long')};
    }
    if (!passwd.isComplex(str)) {
        return {valid: false, msg: msg('contain one upper case, one lower case and one numeric character.')};
    }
    if (passwd.containsRepeat(str)) {
        return {valid: false, msg: msg('not contain repeated characters')};
    }
    if (passwd.containsSequence(str)) {
        return {valid: false, msg: msg('not contain sequences such as 123, abc')};
    }

    return {valid: true, msg: ''};

};

/**
 * Tests if a string contains at least 8 characters long.
 * @returns {Boolean}
 */
passwd.validLength = function(str) {
    return str.length >= 8;
};

/**
 * Tests if a string contains one upper case, one lower case and one numeric character.
 * @returns {Boolean}
 */
passwd.isComplex = function(str) {
    if (str.match(/[A-Z]+/) && str.match(/[a-z]/) && str.match(/[0-9]/)) {
        return true;
    }
    return false;
};

/**
 * Tests if a string contains the same character repeated 3 or more times.
 * @returns {Boolean}
 */
passwd.containsRepeat = function(str) {
    if (str.match(/(.)\1{2,}/)) {
        return true;
    }
    return false;
};

/**
 * Tests if the string `str` contains a sequence of 3 or more
 * consecutive characters or digits. The string is converted to lower-case
 * before checked and sequences can be ascending or descending.
 * @param str {String} String to search
 * @returns {Boolean}
 */
passwd.containsSequence = function(str) {
    str = str.toLowerCase();
    var seqs = ['abcdefghijklmnopqrstuvwxyz', '0123456789'],
        len = 3;
    for (var i = 0, seq; i < seqs.length; i++) {
        seq = seqs[i].toLowerCase();
        if (passwd.containsSubSeq(seq, len, str) ||
            passwd.containsSubSeq(passwd.reverseString(seq), len, str)) {
                return true
        }
    }
    return false;
};

/**
 * Return a new reversed copy of a string.
 * @param str {String} The string to reverse.
 * @return {String}
 */
passwd.reverseString = function(str) {
    return str.split('').reverse().join('');
};

/**
 * Test if a string contains a minimum `len` portion of a sequence.
 * @param seq {String} The sequence of character to test for
 * @param len {Number} The minimum length of the sequence to test.
 * @param str {String} The string to test.
 * @return {Boolean}
 */
passwd.containsSubSeq = function(seq, len, str) {
    for (var i = 0, subSeq; i < seq.length - (len - 1); i++) {
        subSeq = seq.substr(i, len);
        // console.log(subSeq);
        if (str.indexOf(subSeq) > -1) {
            return true;
        }
    }
    return false;
};

// Export for testing in node
if (typeof module === 'object' && typeof module.exports === 'object') {
    module.exports = passwd;
}
