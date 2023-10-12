import React from 'react';

function About() {
    // Content for the About section
    const aboutContent = {
        title: "who are the DacadePunks?",
        description: "The DacadePunks is an art collection for an NFT staking project built within the Celo Alfajores network, a DacadePunk is a character that is part of an 10000 algorithmically generated collection consisting of extremely unique features. Each item can be staked on the DacadePunk vault to receive DacadePunk Token (DPT) rewards."
    };

    return (
        <section className="about bg-light" id='about'>
            <div className="container">
                <div className="row justify-content-center">
                    <div className="col-md-9">
                        <div className="text-center">
                            <h1 className="about-title">{aboutContent.title}</h1>
                            <p className="lead text-center">{aboutContent.description}</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    )
}

export default About;
