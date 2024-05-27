package io.quarkus.experiments;

import java.text.SimpleDateFormat;
import java.util.Date;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/")
public class BootstrapEndpoint {

    @GET
    @Path("/currenttime")
    public String timestamp() {
        return new SimpleDateFormat("HH:mm:ss.SSS").format(new Date());
    }

    @GET
    @Path("/hello")
    public String greeting() {
        return "Hello from Quarkus REST";
    }

}