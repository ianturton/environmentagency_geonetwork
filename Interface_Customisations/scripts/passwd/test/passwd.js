describe('passwd', function() {

    // Allow testing in node and browser
    if (typeof require === 'function') {
        var expect = require('expect.js'),
            passwd = require('../');
    } else {
        var expect = window.expect,
            passwd = window.passwd;
    }

    describe('validPassword', function() {
        it('Valid according to EA password complexity rules', function() {
            // Too short
            expect(passwd.validPassword("aaaaaaa")).to.have.property('valid', false);
            // Not complex enough
            expect(passwd.validPassword("password1")).to.have.property('valid', false);
            // Contains repeated characters
            expect(passwd.validPassword("Paaasword1")).to.have.property('valid', false);
            // Contains a sequence
            expect(passwd.validPassword("Password1abc")).to.have.property('valid', false);
            // Just right
            expect(passwd.validPassword("FooBarCar2")).to.have.property('valid', true);
        });
    });

    describe('validLength', function() {
        it('Is at least 8 characters long', function() {
            expect(passwd.validLength("aaa")).to.be(false);
            expect(passwd.validLength("aaaaaaa")).to.be(false);
            expect(passwd.validLength("aaaaaaaa")).to.be(true);
            expect(passwd.validLength("aaaaaaaaa")).to.be(true);
        });
    });

    describe('isComplex', function() {
        it('Has at least one lower char, upper char and a number', function() {
            expect(passwd.isComplex("aA1")).to.be(true);
            expect(passwd.isComplex("foocarCAR12")).to.be(true);
            expect(passwd.isComplex("password1")).to.be(false);
            expect(passwd.isComplex("Password1")).to.be(true);
            expect(passwd.isComplex("aaa")).to.be(false);
            expect(passwd.isComplex("a1")).to.be(false);
        });
    });

    describe('containsRepeat', function() {
        it('Contains 3 or more repeated characters', function() {
            expect(passwd.containsRepeat("aaa")).to.be(true);
            expect(passwd.containsRepeat("aaabaabbb")).to.be(true);
            expect(passwd.containsRepeat("111aaabaabbb")).to.be(true);
            expect(passwd.containsRepeat("a11aaabaabbb")).to.be(true);
            expect(passwd.containsRepeat("aa")).to.be(false);
            expect(passwd.containsRepeat("foobarcar")).to.be(false);
            expect(passwd.containsRepeat("mooandboo")).to.be(false);
        });
    });

    describe('containsSequence', function() {
        it('Contains a sequence of 3 or more consecutive characters or digits', function() {
            expect(passwd.containsSequence('abc')).to.be(true);
            expect(passwd.containsSequence('cde')).to.be(true);
            expect(passwd.containsSequence('xyz')).to.be(true);
            expect(passwd.containsSequence('zyx')).to.be(true);
            expect(passwd.containsSequence('wxyz')).to.be(true);
            expect(passwd.containsSequence('foocde')).to.be(true);
            expect(passwd.containsSequence('foocdebar')).to.be(true);
            expect(passwd.containsSequence('FOOCDEBAR')).to.be(true);
            expect(passwd.containsSequence('FOOcdEBAR')).to.be(true);
            expect(passwd.containsSequence('cdebar')).to.be(true);
            expect(passwd.containsSequence('0123')).to.be(true);
            expect(passwd.containsSequence('123')).to.be(true);
            expect(passwd.containsSequence('789')).to.be(true);
            expect(passwd.containsSequence('345')).to.be(true);
            expect(passwd.containsSequence('Testuser3')).to.be(true); // Contains "stu"
            expect(passwd.containsSequence('ab')).to.be(false);
            expect(passwd.containsSequence('yz')).to.be(false);
            expect(passwd.containsSequence('foobar')).to.be(false);
            expect(passwd.containsSequence('password!')).to.be(false);
            expect(passwd.containsSequence('notpassword!')).to.be(false);
        });
    });

});
