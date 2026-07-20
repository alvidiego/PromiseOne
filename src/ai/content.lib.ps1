[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "$PSScriptRoot\..\utils\config.ps1"

function Assert-PnProfile {
    param(
        [Parameter(Mandatory)]$Profile,
        [Parameter(Mandatory)][string]$ProfileName
    )

    if ($Profile -is [string] -or $Profile -is [array] -or $Profile -isnot [pscustomobject]) {
        throw "[PROFILE] Profile '$ProfileName' must contain one JSON object."
    }

    $errors = @()
    $propertyNames = @($Profile.PSObject.Properties.Name)

    if ($propertyNames -notcontains 'profile' -or [string]::IsNullOrWhiteSpace([string]$Profile.profile)) {
        $errors += "Missing required field 'profile'."
    }
    elseif (-not [string]::Equals([string]$Profile.profile, $ProfileName, [System.StringComparison]::OrdinalIgnoreCase)) {
        $errors += "Field 'profile' must match filename '$ProfileName.json'."
    }

    if ($propertyNames -notcontains 'brand_name' -or [string]::IsNullOrWhiteSpace([string]$Profile.brand_name)) {
        $errors += "Missing required field 'brand_name'."
    }

    if ($propertyNames -notcontains 'pages' -or $null -eq $Profile.pages) {
        $errors += "Missing required field 'pages'."
    }
    else {
        $pages = @($Profile.pages)
        $invalidPages = @($pages | Where-Object { $_ -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$_) })
        if ($pages.Count -eq 0) {
            $errors += "Field 'pages' must contain at least one page name."
        }
        elseif ($invalidPages.Count -gt 0) {
            $errors += "Field 'pages' must contain only non-empty page names."
        }
    }

    if ($propertyNames -contains 'style' -and -not [string]::IsNullOrWhiteSpace([string]$Profile.style)) {
        $styleName = [string]$Profile.style
        if ($styleName -notmatch '^[a-z0-9]+(?:[-_][a-z0-9]+)*$') {
            $errors += "Field 'style' contains an unsafe template name."
        }
        else {
            $layoutPath = Join-Path (Join-Path $TemplatesRoot $styleName) "layout.html"
            if (-not (Test-Path -LiteralPath $layoutPath -PathType Leaf)) {
                $errors += "Style '$styleName' does not contain a template layout."
            }
        }
    }

    if ($propertyNames -contains 'modules') {
        $modules = $Profile.modules
        if ($null -eq $modules -or $modules -is [string] -or $modules -is [array] -or $modules -isnot [pscustomobject]) {
            $errors += "Field 'modules' must be a JSON object."
        }
    }

    if ($errors.Count -gt 0) {
        $nl = [Environment]::NewLine
        throw ("[PROFILE] Profile '$ProfileName' is invalid." + $nl + "- " + ($errors -join ($nl + "- ")))
    }

    return $Profile
}

function Get-PnProfile {
    param(
        [Parameter(Mandatory)][string]$ProfileName,
        [switch]$Required
    )

    $profileName = $ProfileName.Trim()
    if ($profileName -notmatch '^[a-z0-9]+(?:[-_][a-z0-9]+)*$') {
        throw "[PROFILE] Invalid profile name: '$ProfileName'."
    }

    $profilePath = Join-Path (Join-Path $ContentRoot "profiles") "$profileName.json"

    if (-not (Test-Path -LiteralPath $profilePath -PathType Leaf)) {
        if ($Required) {
            throw "[PROFILE] Profile '$profileName' was not found.`nExpected: $profilePath"
        }
        return $null
    }

    try {
        $profile = Get-Content -LiteralPath $profilePath -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    catch {
        throw "[PROFILE] Profile '$profileName' contains invalid JSON.`nPath: $profilePath`n$($_.Exception.Message)"
    }

    return Assert-PnProfile -Profile $profile -ProfileName $profileName
}

function New-PnPagePlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Goal,
        [Parameter(Mandatory)][string]$Client,
        [Parameter(Mandatory)][string[]]$PageNames,

        [Parameter(Mandatory=$false)]
        [string]$ProfileName = ""
    )

    if ($null -eq $Goal) { $Goal = "" }

    $goalLower = $Goal.ToLowerInvariant()
    $isContracting = ($goalLower -match 'drywall|construction|contractor|remodel|renov|finish|interior|patch|texture')

    $normalized = @()
    foreach ($n in $PageNames) {
        $normalized += [string]$n
    }

    if ($isContracting) {
        $normalized = @("Home", "Services", "Gallery", "About", "Contact")
    }
    elseif (-not $normalized -or $normalized.Count -eq 0) {
        $normalized = @("Home")
    }

    function _PageObj(
    [string]$Name,
    [string]$Lang,
    [string]$Content,
    [string]$ThemeCss = ""
) {
    [pscustomobject]@{
        name        = $Name
        content     = $Content
        layout      = "default"
        head_extras = ""
        theme_css   = $ThemeCss
        lang        = $Lang
    }
}

    $brandName = "Sanchez Interior Finishing"
    $serviceAreaEn = "Serving San Diego, Chula Vista & Surrounding Areas"
    $serviceAreaEs = "Sirviendo San Diego, Chula Vista y Áreas Cercanas"
    $phoneFake = "(619) 555-0182"

    $pages = @()

    $profile = $null

    if ($ProfileName) {
        $profile = Get-PnProfile -ProfileName $ProfileName -Required
    }
    elseif ($isContracting) {
        $profile = Get-PnProfile -ProfileName "drywall" -Required
    }

    if ($profile) {
        if ($profile.PSObject.Properties.Name -contains "pages" -and $profile.pages) {
            $normalized = @()
            foreach ($p in $profile.pages) {
                $normalized += [string]$p
            }
        }

        if ($profile.PSObject.Properties.Name -contains "phone" -and $profile.phone) {
            $phoneFake = [string]$profile.phone
        }

        if ($profile.PSObject.Properties.Name -contains "brand_name" -and $profile.brand_name) {
            $brandName = [string]$profile.brand_name
        }

        if ($profile.PSObject.Properties.Name -contains "service_area_en" -and $profile.service_area_en) {
            $serviceAreaEn = [string]$profile.service_area_en
        }

        if ($profile.PSObject.Properties.Name -contains "service_area_es" -and $profile.service_area_es) {
            $serviceAreaEs = [string]$profile.service_area_es
        }
    }

    $isGxeProfile = $false
    if ($profile -and ($profile.PSObject.Properties.Name -contains "profile") -and ([string]$profile.profile -eq "gxe")) {
        $isGxeProfile = $true
    }

    if ($isGxeProfile) {
        $productName = if ($profile.PSObject.Properties.Name -contains "product_name" -and $profile.product_name) { [string]$profile.product_name } else { "Featured Piece" }
        $productLine = if ($profile.PSObject.Properties.Name -contains "product_line" -and $profile.product_line) { [string]$profile.product_line } else { "Single piece preview" }
        $productVideo = if ($profile.PSObject.Properties.Name -contains "product_video" -and $profile.product_video) { [string]$profile.product_video } else { "" }
        $productVideoStart = if ($profile.PSObject.Properties.Name -contains "product_video_start" -and $null -ne $profile.product_video_start) {
            [Convert]::ToString([double]$profile.product_video_start, [Globalization.CultureInfo]::InvariantCulture)
        } else {
            "0"
        }
        $productVideoDuration = if ($profile.PSObject.Properties.Name -contains "product_video_duration" -and $null -ne $profile.product_video_duration) {
            [Convert]::ToString([double]$profile.product_video_duration, [Globalization.CultureInfo]::InvariantCulture)
        } else {
            "6"
        }
        $holdInstruction = if ($profile.PSObject.Properties.Name -contains "hold_instruction" -and $profile.hold_instruction) { [string]$profile.hold_instruction } else { "Press and hold" }

        $productMedia = if ($productVideo) {
@"
        <div class="piece-media" data-product-media data-video-start="$productVideoStart" data-video-duration="$productVideoDuration">
            <div class="piece-video-frame">
                <div class="piece-media-fallback" role="img" aria-label="$productName"></div>
                <video class="piece-video" muted playsinline preload="auto" aria-hidden="true">
                    <source src="$productVideo" type="video/mp4" />
                </video>
            </div>
        </div>
"@
        } else {
            '        <div class="piece-placeholder" role="img" aria-label="Placeholder clothing silhouette"></div>'
        }

        $content = @"
<section class="gxe-experience" data-stage="arrival" aria-label="GXE featured piece experience">
    <section class="gxe-scene gxe-arrival-scene" aria-label="GXE arrival">
    <div class="gxe-emblem" role="img" aria-label="GXE chrome emblem">
        <span class="gxe-word">
            <img class="gxe-reference gxe-reference-chrome" src="assets/gxe-reference.jpg" alt="" />
            <img class="gxe-reference gxe-reference-full" src="assets/gxe-reference.jpg" alt="" />
        </span>
        <span class="gxe-stones" aria-hidden="true">
            <span class="gxe-stone gxe-stone-01"></span>
            <span class="gxe-stone gxe-stone-02"></span>
            <span class="gxe-stone gxe-stone-03"></span>
            <span class="gxe-stone gxe-stone-04"></span>
            <span class="gxe-stone gxe-stone-05"></span>
            <span class="gxe-stone gxe-stone-06"></span>
            <span class="gxe-stone gxe-stone-07"></span>
            <span class="gxe-stone gxe-stone-08"></span>
            <span class="gxe-stone gxe-stone-09"></span>
            <span class="gxe-stone gxe-stone-10"></span>
            <span class="gxe-stone gxe-stone-11"></span>
            <span class="gxe-stone gxe-stone-12"></span>
        </span>
    </div>

    <button class="gxe-hold" type="button" aria-label="$holdInstruction to reveal GXE">
        <span class="gxe-hold-instruction">$holdInstruction</span>
    </button>
    </section>

    <div class="gxe-bloom" aria-hidden="true"></div>

    <section class="gxe-scene gxe-product-scene" aria-label="Featured product reveal" aria-hidden="true">
    <article class="piece-stage" aria-label="$productName">
        <div class="piece-light" aria-hidden="true"></div>
$productMedia
    </article>
    <nav class="gxe-main-menu" aria-label="GXE main menu">
        <div class="gxe-menu-brand" aria-label="GXE">GXE</div>
        <div class="gxe-menu-current">
            <span class="gxe-menu-product">$productName</span>
            <span class="gxe-menu-line">$productLine</span>
        </div>
        <button class="gxe-menu-action" type="button">Reserve Piece</button>
    </nav>
    </section>
</section>
"@

        return @(_PageObj -Name "Home" -Lang "en" -Content $content)
    }

    foreach ($name in $normalized) {
        $lower = $name.ToLowerInvariant()

        function _ListHtml($Items) {
            $html = "<ul>"
            foreach ($item in $Items) {
                $html += "<li>$([string]$item)</li>"
            }
            $html += "</ul>"
            return $html
        }

        function _TrustGridHtml($Items) {
            $html = '<div class="trust-grid">'

            foreach ($item in $Items) {
                $html += @"
<div class="trust-card">
    <p>$([string]$item)</p>
</div>
"@
            }

            $html += '</div>'
            return $html
        }

        # ---------- EN ----------
        $contentEn = switch -Regex ($lower) {
            '^(home|index)$' {
                $heroTitle = "Drywall Finishing Done Right"
                $heroSubtitle = "Clean work. Smooth finish. Reliable service."
                $ctaText = "Request a Free Estimate"

                $trustHtml = _TrustGridHtml @(
                    "30+ years of hands-on trade experience",
                    "Clean lines, smooth finishes, consistent texture",
                    "Respect for your home: prep, protection, clean-up",
                    "Reliable scheduling and honest updates"
                )

                if ($profile) {
                    if ($profile.PSObject.Properties.Name -contains "hero_en" -and $profile.hero_en) {
                        if ($profile.hero_en.PSObject.Properties.Name -contains "title" -and $profile.hero_en.title) {
                            $heroTitle = [string]$profile.hero_en.title
                        }

                        if ($profile.hero_en.PSObject.Properties.Name -contains "subtitle" -and $profile.hero_en.subtitle) {
                            $heroSubtitle = [string]$profile.hero_en.subtitle
                        }
                    }

                    if ($profile.PSObject.Properties.Name -contains "cta" -and $profile.cta) {
                        $ctaText = [string]$profile.cta
                    }

                    if ($profile.PSObject.Properties.Name -contains "trust_points_en" -and $profile.trust_points_en) {
                        $trustHtml = _TrustGridHtml $profile.trust_points_en
                    }
                }

@"
<section class="hero">
    <div class="hero-inner">
        <div class="hero-copy">
            <h2>$heroTitle</h2>

            <p class="hero-subtitle">
                <strong>$heroSubtitle</strong>
            </p>

            <p class="hero-service-area">
                $serviceAreaEn
            </p>

            <div class="hero-actions">
                <a href="contact.en.html">$ctaText</a>
                <a href="tel:$phoneFake">Call Now</a>
            </div>
        </div>
    </div>
</section>

<hr/>

<section class="content-tight">
    <p><strong>Family Owned & Operated • 30+ Years Experience</strong></p>
    <p><strong>Professional Drywall & Interior Finishing</strong><br/>$serviceAreaEn</p>
</section>

<hr/>

<section class="trust-section content-tight">
    <div class="section-intro">
        <h3>Why homeowners & contractors trust us</h3>
    </div>

    $trustHtml
</section>

<hr/>

<section class="content-tight">
    <h3>Next step</h3>
    <p>Tell us what you need and we’ll get you a fast, honest estimate.</p>
    <p><a href="contact.en.html">$ctaText</a></p>
</section>
"@
            }

            '^services$' {
                $servicesHtml = ""

                if ($profile -and $profile.services) {
                    foreach ($s in $profile.services) {
                        $servicesHtml += @"
<div class="service-card">
    <h3>$([string]$s.title)</h3>
    <p>$([string]$s.description)</p>
</div>
"@
                    }
                }

                $ctaText = "Request a Free Estimate"

                if ($profile -and ($profile.PSObject.Properties.Name -contains "cta") -and $profile.cta) {
                    $ctaText = [string]$profile.cta
                }

@"
<section class="services-section content-medium">
    <div class="section-intro">
        <p><strong>Drywall & interior finishing done right.</strong></p>
    </div>

    <div class="service-grid">
        $servicesHtml
    </div>

    <div class="section-actions">
        <a href="contact.en.html">$ctaText</a>
    </div>
</section>
"@
            }

            '^(gallery|work)$' {
                $galleryItems = @(
                    "Drywall finishing — smooth wall",
                    "Texture match — existing wall blend",
                    "Patch repair — clean seam",
                    "Corner finish — crisp edges",
                    "Ceiling repair — even surface",
                    "Room refresh — clean, ready to paint"
                )

                if ($profile -and ($profile.PSObject.Properties.Name -contains "gallery_en") -and $profile.gallery_en) {
                    $galleryItems = $profile.gallery_en
                }

                $galleryHtml = '<div class="gallery-grid">'

foreach ($item in $galleryItems) {
    $galleryHtml += @"
<div class="gallery-card">
    <div class="gallery-thumb"></div>
    <p>$([string]$item)</p>
</div>
"@
}

$galleryHtml += '</div>'

@"
<section class="gallery-section">
    <div class="section-intro">
        <p>Demo images for now. Replace these with real before/after photos as you collect them.</p>
    </div>

    $galleryHtml

    <div class="section-actions">
        <a href="contact.en.html">Want results like this? Get a Free Estimate</a>
    </div>
</section>
"@
            }

            '^about$' {
@"
<section class="about-section content-tight">
    <div class="about-grid">

        <div class="about-story">
            <p class="eyebrow">About $brandName</p>
            <h3>Family-operated finishing built on real trade experience.</h3>
            <p>We focus on clean prep, strong repairs, smooth finishing, and clear communication from start to finish.</p>
            <p>Every project is handled with respect for the home, the schedule, and the final result.</p>
        </div>

        <div class="about-card">
            <h3>Our Standard</h3>

            <div class="standard-list">
                <div class="standard-item">Respect the home with protection and cleanup</div>
                <div class="standard-item">Build strong repairs and smooth finishes</div>
                <div class="standard-item">Communicate clearly and honestly</div>
            </div>

            <div class="section-actions">
                <a href="contact.en.html">Contact us for a Free Estimate</a>
            </div>
        </div>

    </div>
</section>
"@
}

            '^contact$' {
                $contactIntro = "Free Estimates — tell us what you need and we’ll respond with next steps."
                $contactMessage = "For now, add your email here later. You can also replace this with a real form once you’re ready."

                if ($profile -and ($profile.PSObject.Properties.Name -contains "contact_en") -and $profile.contact_en) {
                    if ($profile.contact_en.PSObject.Properties.Name -contains "intro" -and $profile.contact_en.intro) {
                        $contactIntro = [string]$profile.contact_en.intro
                    }

                    if ($profile.contact_en.PSObject.Properties.Name -contains "message" -and $profile.contact_en.message) {
                        $contactMessage = [string]$profile.contact_en.message
                    }
                }

@"
<section class="contact-section content-tight">
    <div class="contact-grid">

        <div class="contact-card contact-primary">
            <p><strong>$contactIntro</strong></p>

            <h3>Call for a Free Estimate</h3>
            <p class="contact-phone">
                <a href="tel:$phoneFake">$phoneFake</a>
            </p>

            <p>$contactMessage</p>
        </div>

        <div class="contact-card">
            <h3>Project Details</h3>
            <p>When you reach out, include a few quick details so we can respond faster.</p>

            <ul class="contact-checklist">
                <li>Name</li>
                <li>Phone</li>
                <li>Project Type</li>
                <li>Short Description</li>
                <li>Preferred Contact Method</li>
            </ul>
        </div>

    </div>
</section>
[[MODULE:contact-form]]
"@
            }

            default {
@"
<section>
    <p>This page supports the overall goal:</p>
    <p><strong>$Goal</strong></p>
    <p>Replace this content with specifics for this section.</p>
</section>
"@
            }
        }

        # ---------- ES ----------
        $contentEs = switch -Regex ($lower) {
            '^(home|index)$' {
                $heroTitle = "Acabado de Drywall Bien Hecho"
                $heroSubtitle = "Trabajo limpio. Acabado parejo. Servicio confiable."

                $trustHtml = _TrustGridHtml @(
                    "Más de 30 años de experiencia real",
                    "Acabados lisos y textura consistente",
                    "Respeto por su hogar: protección y limpieza",
                    "Horario confiable y comunicación honesta"
                )

                if ($profile) {
                    if ($profile.PSObject.Properties.Name -contains "hero_es" -and $profile.hero_es) {
                        if ($profile.hero_es.PSObject.Properties.Name -contains "title" -and $profile.hero_es.title) {
                            $heroTitle = [string]$profile.hero_es.title
                        }

                        if ($profile.hero_es.PSObject.Properties.Name -contains "subtitle" -and $profile.hero_es.subtitle) {
                            $heroSubtitle = [string]$profile.hero_es.subtitle
                        }
                    }

                    if ($profile.PSObject.Properties.Name -contains "trust_points_es" -and $profile.trust_points_es) {
                        $trustHtml = _TrustGridHtml $profile.trust_points_es
                    }
                }

@"
<section class="hero">
    <div class="hero-inner">
        <div class="hero-copy">
            <h2>$heroTitle</h2>

            <p class="hero-subtitle">
                <strong>$heroSubtitle</strong>
            </p>

            <p class="hero-service-area">
                $serviceAreaEs
            </p>

            <div class="hero-actions">
                <a href="contact.es.html">Pedir Estimación Gratis</a>
                <a href="tel:$phoneFake">Llamar Ahora</a>
            </div>
        </div>
    </div>
</section>

<hr/>

<section class="content-tight">
    <p><strong>Negocio Familiar • Más de 30 Años de Experiencia</strong></p>
    <p><strong>Drywall y Acabados Interiores Profesionales</strong><br/>$serviceAreaEs</p>
</section>

<hr/>

<section class="trust-section content-tight">
    <div class="section-intro">
        <h3>Por qué confían en nosotros</h3>
    </div>

    $trustHtml
</section>

<hr/>

<section class="content-tight">
    <h3>Siguiente paso</h3>
    <p>Cuéntenos qué necesita y le damos una estimación rápida y honesta.</p>
    <p><a href="contact.es.html">Contáctenos</a></p>
</section>
"@
            }

            '^services$' {
                $servicesHtml = ""

                if ($profile -and ($profile.PSObject.Properties.Name -contains "services_es") -and $profile.services_es) {
                    foreach ($s in $profile.services_es) {
                        $servicesHtml += @"
<div class="service-card">
    <h3>$([string]$s.title)</h3>
    <p>$([string]$s.description)</p>
</div>
"@
                    }
                }

                $ctaText = "Pedir Estimación Gratis"

                if ($profile -and ($profile.PSObject.Properties.Name -contains "cta_es") -and $profile.cta_es) {
                    $ctaText = [string]$profile.cta_es
                }

@"
<section class="services-section content-medium">
    <div class="section-intro">
        <p><strong>Drywall y acabados interiores bien hechos.</strong> Enfoque en resultados limpios y trabajo duradero.</p>
    </div>

    <div class="service-grid">
        $servicesHtml
    </div>

    <div class="section-actions">
        <a href="contact.es.html">$ctaText</a>
    </div>
</section>
"@
            }

            '^(gallery|work)$' {
                $galleryItems = @(
                    "Acabado liso",
                    "Igualación de textura",
                    "Parche limpio",
                    "Esquinas bien definidas",
                    "Reparación de techo",
                    "Cuarto listo para pintura"
                )

                if ($profile -and ($profile.PSObject.Properties.Name -contains "gallery_es") -and $profile.gallery_es) {
                    $galleryItems = $profile.gallery_es
                }

                $galleryHtml = '<div class="gallery-grid">'

foreach ($item in $galleryItems) {
    $galleryHtml += @"
<div class="gallery-card">
    <div class="gallery-thumb"></div>
    <p>$([string]$item)</p>
</div>
"@
}

$galleryHtml += '</div>'

@"
<section class="gallery-section">
    <div class="section-intro">
        <p>Imágenes de ejemplo por ahora. Cambie esto por fotos reales con el tiempo.</p>
    </div>

    $galleryHtml

    <div class="section-actions">
        <a href="contact.es.html">¿Quiere resultados así? Estimación Gratis</a>
    </div>
</section>
"@
            }

            '^about$' {
@"
<section class="about-section content-tight">
    <div class="about-grid">

        <div class="about-story">
            <p class="eyebrow">Sobre $brandName</p>
            <h3>Equipo familiar con experiencia real en el oficio.</h3>
            <p>Nos enfocamos en preparación limpia, reparaciones firmes, acabados parejos y comunicación clara desde el inicio hasta el final.</p>
            <p>Cada proyecto se maneja con respeto por su hogar, su tiempo y el resultado final.</p>
        </div>

        <div class="about-card">
            <h3>Nuestro Estándar</h3>

            <div class="standard-list">
                <div class="standard-item">Respetar su hogar con protección y limpieza</div>
                <div class="standard-item">Hacer reparaciones firmes y acabados parejos</div>
                <div class="standard-item">Comunicación clara y honesta</div>
            </div>

            <div class="section-actions">
                <a href="contact.es.html">Contáctenos para Estimación Gratis</a>
            </div>
        </div>

    </div>
</section>
"@
}

            '^contact$' {
                $contactIntro = "Estimaciones Gratis — díganos qué necesita y le respondemos con los próximos pasos."
                $contactMessage = "Por ahora, agregue su email aquí después. También puede convertir esto en un formulario real más adelante."

                if ($profile -and ($profile.PSObject.Properties.Name -contains "contact_es") -and $profile.contact_es) {
                    if ($profile.contact_es.PSObject.Properties.Name -contains "intro" -and $profile.contact_es.intro) {
                        $contactIntro = [string]$profile.contact_es.intro
                    }

                    if ($profile.contact_es.PSObject.Properties.Name -contains "message" -and $profile.contact_es.message) {
                        $contactMessage = [string]$profile.contact_es.message
                    }
                }

@"
<section class="contact-section content-tight">
    <div class="contact-grid">

        <div class="contact-card contact-primary">
            <p><strong>$contactIntro</strong></p>

            <h3>Llame para una Estimación Gratis</h3>
            <p class="contact-phone">
                <a href="tel:$phoneFake">$phoneFake</a>
            </p>

            <p>$contactMessage</p>
        </div>

        <div class="contact-card">
            <h3>Detalles del Proyecto</h3>
            <p>Cuando nos contacte, incluya algunos detalles para responder más rápido.</p>

            <ul class="contact-checklist">
                <li>Nombre</li>
                <li>Teléfono</li>
                <li>Tipo de proyecto</li>
                <li>Descripción breve</li>
                <li>Método de contacto preferido</li>
            </ul>
        </div>

    </div>
</section>
[[MODULE:contact-form]]
"@
            }

            default {
@"
<section>
    <p>Esta página apoya la meta:</p>
    <p><strong>$Goal</strong></p>
    <p>Reemplace este contenido con detalles específicos.</p>
</section>
"@
            }
        }

        $pages += _PageObj -Name $name -Lang "en" -Content $contentEn
        $pages += _PageObj -Name $name -Lang "es" -Content $contentEs
    }

    return $pages
}
