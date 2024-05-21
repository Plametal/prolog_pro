:- dynamic(father/2).
:- dynamic(likes/2).
:- dynamic(friend/2).

father(lord_montague, romeo).
father(lord_capulet, juliet).

likes(mercutio, dancing).
likes(benvolio, dancing).
likes(romeo, dancing).
likes(remeo, juliet).
likes(juliet, romeo).
likes(juliet, dancing).

friend(romeo, mercutio).
friend(romeo, benvolio).

stabs(tybalt, mercutio, sword).
stabs(romeo, tybalt, sword).
