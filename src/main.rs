use std::{num::NonZeroU64, str::FromStr};
use wgpu::{util::DeviceExt, Adapter, Instance};
use artnet_protocol::*;
use std::net::{ToSocketAddrs, UdpSocket};

fn setup_artnet_socket<A: ToSocketAddrs>(receive: A, send: A) -> UdpSocket {
    let socket = UdpSocket::bind(receive).unwrap();
    /*
    let broadcast_addr = send 
        .to_socket_addrs()
        .unwrap()
        .next()
        .unwrap();
    socket.set_broadcast(true).unwrap();
    let buff = ArtCommand::Poll(Poll::default()).write_to_buffer().unwrap();
    socket.send_to(&buff, &broadcast_addr).unwrap();
    */
    socket
}

fn main() {
    env_logger::init();

    let addr = ("0.0.0.0", 6454);
    let broadcast = ("255.255.255.255", 6454);

    let artnet_socket = setup_artnet_socket(addr, broadcast);

    println!("Listening");
    loop {
        let mut buffer = [0u8; 1024];
        let (length, _addr) = artnet_socket.recv_from(&mut buffer).unwrap();
        let command = ArtCommand::from_buffer(&buffer[..length]).unwrap();

        println!("Received {:?}", command);
        match command {
            ArtCommand::Output(output) => {
                println!(
                    "port {:?} data: {:?}",
                    u16::from(output.port_address),
                    output.data
                )
            }
            _ => {}
        }
    }
}