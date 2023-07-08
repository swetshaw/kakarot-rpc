HURL_FILES = $(shell find ./rpc-call-examples/ -name '*.hurl')

pull-kakarot: .gitmodules 
	git submodule update --init --recursive
	cd lib/kakarot && make setup

build-kakarot: setup 
	cd lib/kakarot && make build && make build-sol

setup: pull-kakarot build-kakarot

# run devnet
devnet: 
	docker run --rm -it -p 5050:5050 -v $(PWD)/deployments:/app/kakarot/deployments -e STARKNET_NETWORK=katana ghcr.io/kkrt-labs/kakarot/katana:latest

# build
build:
	cargo build --all --release

# run
run: 
	source .env && RUST_LOG=debug cargo run -p kakarot-rpc

#run-release
run-release:
	source .env && cargo run --release -p kakarot-rpc

test:
	cargo test --all

test-coverage:
	cargo llvm-cov --all-features --workspace --lcov --output-path lcov.info

test-examples:
	hurl $(HURL_FILES)

.PHONY: install run devnet test