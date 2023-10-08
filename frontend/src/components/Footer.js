import React from 'react'
import { AiOutlineTwitter, AiOutlineGithub } from "react-icons/ai";
import { RiDiscordFill } from "react-icons/ri";

function Footer() {
    return (
        <div className='footer container'>
            <p>DacadePunks&#169; All Right Reserved</p>
            <div className='social'>
                <a href='https://github.com/haruharuxyz' >
                    <AiOutlineGithub size={24} color="#000" />
                </a>
                <a href='https://github.com/haruharuxyz' >
                    <AiOutlineTwitter size={24} color="#000" />
                </a>
                <a href='https://github.com/haruharuxyz' >
                    <RiDiscordFill size={24} color="#000" />
                </a>
            </div>
        </div>
    )
}

export default Footer