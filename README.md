Allocate enough memory to the VM so that WordPress performs reasonably well:


    VM_RAM=3000 vagrant up


Log in:


    vagrant ssh

Create the image:


    make image

Test the image:

```
make test
```
