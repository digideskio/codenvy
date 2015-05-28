/*
 * CODENVY CONFIDENTIAL
 * __________________
 *
 *  [2012] - [2015] Codenvy, S.A.
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Codenvy S.A. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Codenvy S.A.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Codenvy S.A..
 */
package com.codenvy.im.response;

import com.codenvy.im.artifacts.Artifact;
import com.codenvy.im.utils.Version;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

import java.nio.file.Path;

/** @author Dmytro Nochevnov */
@JsonPropertyOrder({"artifact", "version", "file", "status"})
public class ArtifactInfo {
    private String         artifact;
    private String         version;
    private ArtifactStatus status;
    private String         file;

    public ArtifactInfo() {
    }

    public ArtifactInfo(Artifact artifact, Version version) {
        this(artifact.getName(), version.toString(), null, null);
    }

    public ArtifactInfo(Artifact artifact, Version version, ArtifactStatus status) {
        this(artifact.getName(), version.toString(), null, status);
    }

    public ArtifactInfo(Artifact artifact, Version version, Path file, ArtifactStatus status) {
        this(artifact.getName(), version.toString(), file.toString(), status);
    }

    private ArtifactInfo(String artifact, String version, String file, ArtifactStatus status) {
        this.artifact = artifact;
        this.version = version;
        this.file = file;
        this.status = status;
    }

    public String getArtifact() {
        return artifact;
    }

    public ArtifactInfo setArtifact(String artifact) {
        this.artifact = artifact;
        return this;
    }

    public String getVersion() {
        return version;
    }

    public ArtifactInfo setVersion(String version) {
        this.version = version;
        return this;
    }

    public ArtifactStatus getStatus() {
        return status;
    }

    public ArtifactInfo setStatus(ArtifactStatus status) {
        this.status = status;
        return this;
    }

    public String getFile() {
        return file;
    }

    public ArtifactInfo setFile(String file) {
        this.file = file;
        return this;
    }

}
