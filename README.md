How to compile:
===============

Using make(works on linux, and should work on MacOS):

> make build-app
> make build-cli

Using dub(should work on any system):

> dub build :app
> dub build :cli

How to use it:
==============

You need:
1. Create a DB(run command `./dlang_demo_cli start`).
2. Register admin user who can manage products. For that run command `run command ./dlang_demo_cli addAdmin {username} {email} {password}`
3. Run an application: `./dlang_demo_app`

If you made any changes, stop application, then recompile and run it. You may do it in one command:

> make run-app
OR
> dub run :app

Features
--------

1. Anonimous user can browser the products.
2. Registered user can browser the products, add it to cart, and manage own cart.
3. Admin user can browser the products, add it to cart, manage own cart and manage all products on the site.
