import socket
from web3 import Web3
import json

w3 = Web3(Web3.HTTPProvider("http://BlockchainhostIP:port"))
assert w3.is_connected(), "Web3 connection failed"

account = w3.eth.accounts[0]

with open("Test1.json", "r") as file:
    JS = json.load(file)
    abi = JS['abi']
    bytecode = JS['bytecode']

import os

def save_string(data):
    CONTRACT_ADDRESS_FILE = "contract_address.txt"

    if os.path.exists(CONTRACT_ADDRESS_FILE):
        with open(CONTRACT_ADDRESS_FILE, "r") as file:
            contract_address = file.read().strip()
        print(f"Using existing contract at: {contract_address}")

    contract = w3.eth.contract(address=contract_address, abi=abi)
    tx = contract.functions.setString(data).transact({"from": account})
    w3.eth.wait_for_transaction_receipt(tx)

def is_json(data):
    try:
        json.loads(data)
        return True
    except ValueError:
        return False

while(1):
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    host = 'Your Host IP'
    port = 12345

    server_socket.bind((host, port))

    server_socket.listen(1)
    print(f"Getting credentials using {host}:{port}")

    client_socket, client_address = server_socket.accept()
    print(f"Connection from {client_address} has been established.")

    data = client_socket.recv(1024).decode()
    if(is_json(data)):
        print(f"Received JSON: {data}")
        save_string(data)
    else:
        print("Data not in JSON format")

    client_socket.close()
    server_socket.close()
