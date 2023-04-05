# Wipe all KERNEL_OBJ folders including other devices kernel objects
$(call add-clean-step, rm -rf $(wildcard out/target/product/*/obj/KERNEL_OBJ))
