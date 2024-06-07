package io.quarkus.experiments;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;

@Path("/")
public class BootstrapEndpoint {

    @GET
    @Path("/currenttime")
    public String timestamp() {
        //Just print the milliseconds from epoch as it simplifies delta computation.
        return "" + System.currentTimeMillis();
    }

    @GET
    @Path("/hello")
    public String greeting() {
        return "Hello from Quarkus REST";
    }

}